//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import OSLog

public struct Cache: Equatable, Sendable {
    let cacheURL: URL

    // helper function used to build URL during initialization

    static func cacheURL(name: String, group: String? = nil) -> URL {
        // build the URL to the cache file using the given name and group

        let folder: URL
        let fileManager = FileManager.default

        // yes, the following will crash if the group identifier is bad
        // or the module doesn't have an identifier.

        if let group {
            folder = fileManager.containerURL(forSecurityApplicationGroupIdentifier: group)!
        } else {
            folder = URL.cachesDirectory
        }
        Logger(subsystem: "Cache", category: "user").info("""
            Cache Folder for \(name, privacy: .public) is \
            \(folder.path, privacy: .public)
            """)
        return folder.appendingPathComponent(name)
    }

    public init(name: String, bundleURL: URL, group: String? = nil) {
        cacheURL = Cache.cacheURL(name: name, group: group)

        // if the cache doesn't exist create and initialize it from
        // data stored in the bundle. Abort on failure

        if !FileManager.default.fileExists(atPath: cacheURL.path) {
            prime(from: bundleURL)
        }
    }

    public func read<T: Decodable>(type: T.Type) -> T {
        let logger = Logger(subsystem: "Cache", category: "user")
        if let data = try? Data(contentsOf: cacheURL) {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(type, from: data)
                return decoded
            } catch let DecodingError.dataCorrupted(context) {
                logger.error("context: \(context.debugDescription, privacy: .public)")
            } catch let DecodingError.keyNotFound(key, context) {
                logger.error("""
                    Key '\(key.debugDescription, privacy: .public)' not found: \
                    \(context.debugDescription, privacy: .public)
                    codingPath: \(context.codingPath, privacy: .public)
                    """)
            } catch let DecodingError.valueNotFound(value, context) {
                logger.error("""
                    Value '\(value, privacy: .public)' not found: \
                    \(context.debugDescription, privacy: .public)
                    codingPath: \(context.codingPath, privacy: .public)
                    """)
            } catch let DecodingError.typeMismatch(type, context) {
                logger.error("""
                    Type '\(type, privacy: .public)' not found: \
                    \(context.debugDescription, privacy: .public)
                    codingPath: \(context.codingPath, privacy: .public)
                    """)
            } catch {
                logger.error("Error: \(error.localizedDescription, privacy: .public)")
            }
            fatalError("JSON Decoding Error for \(cacheURL.path)")
        } else {
            fatalError("Cannot read data from \(cacheURL.path)")
        }
    }

    public func write(_ data: Data) {
        // create local copy of URL to pass to task
        let cacheURL = cacheURL
        Task(priority: .background) {
            do {
                try data.write(to: cacheURL)
            } catch {
                Logger().error("""
                    Failed to update cache for \
                    \(cacheURL.path, privacy: .public)
                    Error: \(error.localizedDescription, privacy: .public)
                    """)
            }
        }
    }

    private func prime(from url: URL) {
        let logger = Logger(subsystem: "Cache", category: "user")

        logger.info("""
            priming \(cacheURL.path, privacy: .public) \
            from \(url.path, privacy: .public)
            """)

        do {
            try FileManager.default.copyItem(at: url, to: cacheURL)
            logger.notice("\(cacheURL, privacy: .public) primed")
        } catch {
            logger.error("""
                Failed to prime cache at \
                \(cacheURL, privacy: .public)
                from url location \
                \(url, privacy: .public)
                """)
            fatalError("Cannot prime cache: \(cacheURL)")
        }
    }
}
