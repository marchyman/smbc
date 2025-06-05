//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Cache
import Downloader
import Foundation
import OSLog

public struct GalleryModel: Equatable, Sendable {
    public var names: [String] = []

    public init(cache: Cache) {
        names = cache.read(type: [String].self)
    }
}

// Extension to fetch markdown content from the gallery server

extension GalleryModel {

    nonisolated static func fetchMarkdown(
        mdFile name: String,
        start: Bool = false
    ) async throws -> String {
        if let url = URL(string: name) {
            let configuration = URLSessionConfiguration.default
            let session = URLSession(
                configuration: configuration,
                delegate: nil, delegateQueue: nil)
            do {
                let (data, _) = try await session.data(from: url)
                if let content = String(data: data, encoding: .utf8) {
                    let workingString = content.replacing(/!{|!}|!\[.*\)/, with: "")
                    if start {
                        if workingString.count < 250 {
                            return workingString
                        }
                        return String(workingString
                                        .prefix(250)
                                        .replacing(/[[:space:]][^[:space:]]+$/, with: "")
                        ) + "..."
                    } else {
                        return workingString
                    }
                }
            }
        }
        return ""
    }
}
