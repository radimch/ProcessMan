//
//  CSVTableView.swift
//  ProcessMan
//
//  Created by Radim Chlad on 17.04.2025.
//

import SwiftUI

struct CSVTableView: View {
    @ObservedObject var viewModel: CSVViewModel
    @State private var selectedRowSet: Set<CSVRow.ID> = []
    
    @State private var searchColumnIndex = 6
    @State private var searchText: String = ""
    var filteredRows: [CSVRow] {
        if searchText.count < 2 {
            sortedRows
        } else {
            sortedRows.filter { $0.cells[searchColumnIndex].content.lowercased().contains(searchText.lowercased()) }
        }
    }
    @State private var sortColumnIndex: Int? = 4
    @State private var sortAscending = true

    var sortedRows: [CSVRow] {
        guard let column = sortColumnIndex else { return viewModel.rows }

        return viewModel.rows.sorted {
            let lhs = $0.cells[column].content
            let rhs = $1.cells[column].content

            // Try numeric sort first, fallback to string
            if let lhsInt = Int(lhs), let rhsInt = Int(rhs) {
                return sortAscending ? lhsInt < rhsInt : lhsInt > rhsInt
            } else {
                return sortAscending ? lhs < rhs : lhs > rhs
            }
        }
    }
    
    var body: some View {
        Form {
            Spacer().frame(height: 5)
                HStack {
                    Spacer().frame(width: 5)
                    TextField("Date :", text: .constant(viewModel.date)).frame(width: 210).multilineTextAlignment(.trailing)
                    TextField("Total processes :", text: .constant(String(viewModel.totalProcesses))).frame(width: 150).multilineTextAlignment(.trailing)
                    TextField("uname -a: ", text:$viewModel.uname).onAppear {
                        viewModel.getProcesses()
                    }
                    Spacer().frame(width: 5)
                }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        NavigationStack {
            HStack {
                ForEach(viewModel.headers.indices, id: \.self) { columnIndex in
                    Button(action: {
                        if sortColumnIndex == columnIndex {
                            sortAscending.toggle()
                        } else {
                            sortColumnIndex = columnIndex
                            sortAscending = true
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(viewModel.headers[columnIndex].name)
                                .bold()
                            if sortColumnIndex == columnIndex {
                                Text(sortAscending ? "↑" : "↓")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
           Table(of: CSVRow.self, selection: $selectedRowSet,
                  columnCustomization: $viewModel.tableCustomization)  {
                 TableColumnForEach(viewModel.headers) { header in
                    TableColumn(header.name) { row in
                        TextField("Cell value", text: viewModel.cellBinding(for: row, header: header))
                    }
                    .customizationID(header.id.uuidString)
                }
            } rows: {
                ForEach(filteredRows) { row in
                    TableRow(row)
                        .contextMenu {
                            Button("Delete") {
                                withAnimation(.bouncy(duration: 2)) {
                                    viewModel.delete(row: row, selection: selectedRowSet)
                                }
                            }
                        }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Processes on current MacOS")
        }
        .searchable(text: $viewModel.searchText)
    }
}

#Preview {
    CSVTableView(viewModel: CSVViewModel.preview)
}
