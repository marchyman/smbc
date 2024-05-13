//
//  LogView.swift
//  smbc
//
//  Created by Marco S Hyman on 4/28/24.
//  Copyright © 2024 Marco S Hyman. All rights reserved.
//

import SwiftUI

struct LogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var logEntries: [String] = []

    var body: some View {
        VStack {
            HStack {
                Button {
                    logEntries = Downloader.logEntries()
                } label: {
                    Text("Refresh list")
                }
                Spacer()
                Button("Dismiss") {
                    dismiss()
                }
            }
            .padding()

            List(logEntries, id: \.self) { entry in
                Text(entry)
            }
            .listStyle(.plain)
            .padding()
        }
        .onAppear {
            logEntries = Downloader.logEntries()
        }
    }
}

#Preview {
    LogView()
}
