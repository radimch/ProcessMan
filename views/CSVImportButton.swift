//
//  CSVImportButton.swift
//  ProcessMan
//
//  Created by Radim Chlad on 16.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVImportButton: View {
    @ObservedObject var viewModel: CSVViewModel
    @State private var isPresented: Bool = false
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Label("Import CSV", systemImage:
                    "square.and.arrow.down")
        }
        .fileImporter(isPresented: $isPresented,
                      allowedContentTypes: [UTType.commaSeparatedText]) { result in
            viewModel.handleFileImport(for: result)
        }
        .help("Import data from saved CSV file.")
    }
}

#Preview {
    CSVImportButton(viewModel: CSVViewModel())
}
