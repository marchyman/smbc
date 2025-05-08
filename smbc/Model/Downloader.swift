//
//  Downloader.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//

import Foundation
import OSLog

// Ecapsulate a generic version of the code to download the various bits
// of data that make up the program model.
struct Downloader {

    // Logging to help diagnose potential downloader issues

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "Downloader")

    /// Fetch data from url and store in a local cache. Decode the data as JSON.
    ///
    /// - Parameter name:   The name of the locally cached file
    /// - Parameter url:    The url of a file to download
    /// - Parameter type:   The type of structure that should match
    ///                     the downloaded data
    /// - Returns:          Decoded downloaded data
    ///
    nonisolated static func fetch<T: Decodable>(
        name: String,
        url: URL,
        type: T.Type
    ) async throws -> T {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(
            configuration: configuration,
            delegate: nil, delegateQueue: nil)
        let decoder = JSONDecoder()
        do {
            let (data, _) = try await session.data(from: url)
            let decodedData = try decoder.decode(type, from: data)
            // update the cache in the background
            Task(priority: .background) {
                let cache = Cache(name: name, type: type)
                let cacheUrl = cache.fileUrl()
                try data.write(to: cacheUrl)
            }
            logger.notice("\(url.path, privacy: .public) downloaded")
            return decodedData
        } catch {
            logger.error(
                """
                \(#function) \(name, privacy: .public) \
                \(url, privacy: .public) \
                \(error.localizedDescription, privacy: .public)
                """)
            throw error
        }
    }

    // function to get any messages logged by the downloader
    static func logEntries() -> [String] {
        var entries: [String] = []
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
        do {
            let subsystem = Bundle.main.bundleIdentifier!
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            let myEntries = try logStore.getEntries()
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == subsystem }
            if myEntries.isEmpty {
                entries.append("No log entries found")
            } else {
                for entry in myEntries {
                    let formattedTime = timeFormatter.string(from: entry.date)
                    let formatedEntry =
                        "\(formattedTime):  \(entry.category)  \(entry.composedMessage)"
                    entries.append(formatedEntry)
                }
            }
        } catch {
            Task { @MainActor in
                logger.error(
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
