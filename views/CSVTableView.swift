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
    
    @State private var searchText: String = ""
    var filteredRows: [CSVRow] {
        if searchText.count < 2 {
            sortedRows
        } else {
            sortedRows.filter { $0.cells[4].content.lowercased().contains(searchText.lowercased()) }
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
        NavigationStack {
            Table(of: CSVRow.self, selection: $selectedRowSet,
                  columnCustomization: $viewModel.tableCustomization) {
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
