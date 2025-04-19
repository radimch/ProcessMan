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
            let content = shell("""
                     ps aux | awk 'NR >= 1 {
                         for (i = 1; i < 5; i++) {
                             printf "%s%s", $i, ";"
                         }
                         for (i = 11; i <= NF; i++) {
                             printf "%s%s", $i, (i==NF ? ORS : OFS)
                         }
                     }' | tr -d '"'
                """)
            viewModel.content = content
            viewModel.parseCSV(content: content)
        },
            label: {Label("Get processes", systemImage:
                        "arrow.clockwise.square")})
        }
 }


#Preview {
    ProcessGetButton(viewModel: CSVViewModel())
}
