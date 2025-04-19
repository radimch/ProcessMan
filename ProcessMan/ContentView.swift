//
//  ContentView.swift
//  ProcessMan
//
//  Created by Radim Chlad on 16.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CSVViewModel()
    var body: some View {
      CSVTableView(viewModel: viewModel)
        .toolbar {
            ProcessGetButton(viewModel: viewModel)
            CSVExportButton(viewModel: viewModel)
            CSVImportButton(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
