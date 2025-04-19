//
//  ProcessGetButton.swift
//  ProcessMan
//
//  Created by Radim Chlad on 17.04.2025.
//

import SwiftUI

struct ProcessGetButton: View {
    @ObservedObject var viewModel: CSVViewModel
    @State private var isPresented: Bool = false
    var body: some View {
        Button(action: {
            isPresented.toggle()
            viewModel.getProcesses()
        },
               label: {Label("Get processes", systemImage:
                                "arrow.clockwise.square")
        })
        .help("Run ps aux command in system shell and display output in table view")
    }
 }


#Preview {
    ProcessGetButton(viewModel: CSVViewModel())
}
