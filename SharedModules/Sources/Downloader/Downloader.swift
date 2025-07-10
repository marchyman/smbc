//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Cache
import Foundation
import OSLog

public struct Downloader<T: Decodable & SendableMetatype>: Sendable {
    let url: URL
    let cache: Cache?
    let decodeType: T.Type

    public init(_ url: URL, cache: Cache?, decodeType: T.Type) {
        self.url = url
        self.cache = cache
        self.decodeType = decodeType
    }

    public func fetchJSON() async throws -> T {
        let logger = Logger(subsystem: "org.snafu", category: "Downloader")
        logger.debug("\(url, privacy: .public) download request")
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(
            configuration: configuration,
            delegate: nil, delegateQueue: nil)
        let decoder = JSONDecoder()
        do {
            let (data, _) = try await session.data(from: url)
            logger.debug("\(url, privacy: .public) downloaded")
            cache?.write(data)
            let decodedData = try decoder.decode(decodeType, from: data)
            logger.notice("\(url.path, privacy: .public) decoded")
            return decodedData
        } catch {
            logger.error(
                """
                \(#function) \(url, privacy: .public) \
                \(error.localizedDescription, privacy: .public)
                """)
            throw error
        }
    }
}
