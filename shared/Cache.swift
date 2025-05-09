//
//  Cache.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//

import Foundation
import OSLog

let groupID = "group.org.snafu.smbc"

struct Cache<T: Decodable> {
    var name: String
    var type: T.Type

    private let logger = Logger(subsystem: groupID, category: "Cache")

    /// Return a URL for the named cache file
    ///
    /// Cached files live in the app shared folder identifed by groupID.
    /// The folder will be created if it does not exist.
    /// If the cached file does not exist primeCache() is
    /// called to prime the cache with data stored in the bundle.
    ///
    func fileUrl() -> URL {
        let fileManager = FileManager.default
        do {
            let sharedFolder = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID)!
            try fileManager.createDirectory(
                at: sharedFolder,
                withIntermediateDirectories: true,
                attributes: nil)
            let cacheUrl = sharedFolder.appendingPathComponent(name)
            if !fileManager.fileExists(atPath: cacheUrl.path) {
                primeCache(at: cacheUrl)
            }
            logger.info("""
                Cache for \(name, privacy: .public) -> \
                \(cacheUrl.path, privacy: .public)
                """)
            return cacheUrl
        } catch {
            fatalError("Cannot create cache folder for: \(name)")
        }
    }

    /// Return cached data for this name/type
    ///
    func cachedData() -> T {
        let url = fileUrl()
        if let cachedData = try? Data(contentsOf: url) {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(type, from: cachedData)
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
            fatalError("JSON Decoding Error for \(name)")
        } else {
            fatalError("Cannot read cached data for \(name)")
        }
    }

    /// Prime the cache from data stored in the bundle
    /// - Parameter cacheUrl: URL of named file in cache folder
    ///
    func primeCache(at cacheUrl: URL) {
        do {
            // break the name into base name and extension
            guard let dotIndex = name.lastIndex(of: ".") else {
                fatalError("malformed resource name: \(name)")
            }
            let resource = String(name.prefix(upTo: dotIndex))
            let extRange = name.index(after: dotIndex) ..< name.endIndex
            let ext = String(name[extRange])

            // URL to data in bundle
            // No bundle for the widget -- but the widget wont run
            // until the app has been run once which will prime the
            // cache. I think.  Anyway, don't do anything if bundle
            // resourced don't exist.  The widget will use sample data
            // if needed.
            if let bundleUrl = Bundle.main.url(
                forResource: resource,
                withExtension: ext) {
                try FileManager.default.copyItem(at: bundleUrl, to: cacheUrl)
            }
        } catch {
            fatalError("Cannot prime cache: \(name)")
        }
    }
}
