//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import OSLog
import SwiftUI

struct LogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var logEntries: [String] = []

    var body: some View {
        VStack {
            HStack {
                Button {
                    logEntries = fetchLogEntries()
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
            logEntries = fetchLogEntries()
        }
    }

    func fetchLogEntries() -> [String] {
        var entries: [String] = []
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
        do {
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            let myEntries = try logStore.getEntries()
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.category == "user" }
            if myEntries.isEmpty {
                entries.append("No log entries found")
            } else {
                for entry in myEntries {
                    let formattedTime = timeFormatter.string(from: entry.date)
                    let formatedEntry =
                    "\(formattedTime): [\(entry.subsystem)] \(entry.composedMessage)"
                    entries.append(formatedEntry)
                }
            }
        } catch {
            Task {
                Logger(subsystem: "LogView", category: "user").error(
                    """
                    failed to access log store: \
                    \(error.localizedDescription, privacy: .public)
                    """)
            }
            entries.append("Failed to access log store: \(error.localizedDescription)")
        }

        return entries
    }
}

#Preview {
    LogView()
}
