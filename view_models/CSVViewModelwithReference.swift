//
//  CSVViewModelwithReference.swift
//  ProcessMan
//
//  Created by Radim  Chlad on 18.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers

extension CSVViewModel: ReferenceFileDocument {
    
    static let readableContentTypes: [UTType] = [.commaSeparatedText]
    func snapshot(contentType: UTType) throws -> Data {
        exportContent().data(using: .utf8) ?? Data()
    }
    func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
}

extension CSVViewModel {
    func exportContent() -> String {
        let headersx = filteredHeaders()
        let rowsx = filteredRows(for: headersx)
        
        let headerRow = headersx.map { $0.name }.joined(separator: ",")
        let dataRows = rowsx.map { row in
            row.cells.map { $0.exportContent }.joined(separator: ",")
        }
        return ([headerRow] + dataRows).joined(separator: "\n")
    }
    
    func filteredHeaders() -> [CSVHeader] {
        var filteredHeaders: [CSVHeader] = []
        for header in self.headers {
            if tableCustomization[visibility: header.id.uuidString] != .hidden {
                filteredHeaders.append(header)
            }
        }
        return filteredHeaders
    }
    
    func filteredRows(for headers: [CSVHeader]) -> [CSVRow] {
        var filteredRows: [CSVRow] = []
        for row in self.rows {
            var copy = CSVRow(cells: [CSVCell]())
            for header in headers {
                copy.cells.append(row.cells[header.columnIndex])
            }
            filteredRows.append(copy)
        }
        return filteredRows
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

