//
//  CSVExportButton.swift
//  ProcessMan
//
//  Created by Radim  Chlad on 18.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVExportButton: View {
    @ObservedObject var viewModel: CSVViewModel
    @State private var isPresented: Bool = false
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Label("Export CSV", systemImage: "square.and.arrow.up")
        }
        .disabled(viewModel.content.isEmpty)
        .fileExporter(isPresented: $isPresented, document: viewModel,
                      contentType: UTType.commaSeparatedText) { result in
            print("result: \(result)")
        }
    }
}

#Preview {
    CSVExportButton(viewModel: CSVViewModel.preview)
        .frame(width: 300, height: 100)
}
