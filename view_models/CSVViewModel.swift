//
//  CSVViewModel.swift
//  ProcessMan
//
//  Created by Radim Chlad on 16.04.2025.
//

import SwiftUI
import SwiftCSV

class CSVViewModel: ObservableObject {
    @Published var date: String = ""
    @Published var uname: String = ""
    @Published var totalProcesses: Int = 0
    
    @Published var content: String = ""
    @Published var headers: [CSVHeader] = []
    @Published var rows: [CSVRow] = []
    @Published var tableCustomization: TableColumnCustomization<CSVRow> = .init()
    @Published var searchText: String = ""
    init() {
    }
    
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        guard let fileContent = String(data: data, encoding: .utf8) else { return }
        self.content = fileContent
        parseCSV(content: fileContent)
    }
    
    func handleFileImport(for result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            readFile(url)
        case .failure(let error): print("error loading file \(error)")
        }
    }

    func readFile(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            self.content = content
            self.uname = "unknown"
            self.date = "unknown"
            parseCSV(content: content)
        } catch {
            print(error)
        }
        url.stopAccessingSecurityScopedResource()
    }
    
    func parseCSV(content: String) {
        do {
            let data = try EnumeratedCSV(string: content, loadColumns: false)
            self.headers = CSVHeader.createHeaders(data: data.header)
            self.rows = data.rows.map({ CSVRow(cells: $0.map({CSVCell(content: $0)}))})
            self.totalProcesses = rows.count
        } catch {
            print(error)
        }
    }
    
    func delete(row: CSVRow, selection: Set<CSVRow.ID>) {
        if selection.contains(row.id) {
            self.rows.removeAll {selection.contains($0.id) }
        } else {
            self.rows.removeAll(where: {$0.id == row.id})
        }
    }
    
    func cellBinding(for row: CSVRow, header: CSVHeader) -> Binding<String> {
        Binding {
            if (row.cells.count > header.columnIndex) {
                return row.cells[header.columnIndex].content
            } else { return ""}
        } set: { newValue in
            if let rowIndex = self.rows.firstIndex(of: row) {
                self.rows[rowIndex].cells[header.columnIndex].content = newValue
            }
        }
    }
    
    func getProcesses() {
        let content = shell("""
                 ps aux | awk 'NR >= 1 {
                     for (i = 1; i < 5; i++) {
                         printf "%s%s", $i, ";"
                     }
                     for (i = 9; i < 11; i++) {
                         printf "%s%s", $i, ";"
                     }
                     for (i = 11; i <= NF; i++) {
                         printf "%s%s", $i, (i==NF ? ORS : OFS)
                     }
                 }' | tr -d '"'
            """)
        self.content = content
        self.parseCSV(content: content)
        let date = shell("""
            date "+%Y%m%d-%H%M%S-%Z" | tr -d "\n"
        """)
        self.date = date
        
        let uname = shell("""
            uname -a
        """)
        self.uname = uname
    }
    
    static var preview: CSVViewModel {
        let vm = CSVViewModel()
        vm.content = sampleCSV
        vm.parseCSV(content: sampleCSV)
        return vm
    }
    
    static var sampleCSV: String {
        """
        Keyword, Keywor2
        value, value
        value, value
        value, value
        value, value
        value, value
        value, value
        """
    }
}
