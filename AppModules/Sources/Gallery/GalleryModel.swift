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
        from server: String,
        start: Bool = false
    ) async throws -> String {
        let urlPath = "\(server)/raw.php?\(name)"
        if let url = URL(string: urlPath) {
            let configuration = URLSessionConfiguration.default
            let session = URLSession(
                configuration: configuration,
                delegate: nil, delegateQueue: nil)
            do {
                let (data, _) = try await session.data(from: url)
                if let content = String(data: data, encoding: .utf8) {
                    var index = content.startIndex
                    // strip metadata if found
                    if content.hasPrefix("---") {
                        index = content.index(content.startIndex, offsetBy: 3)
                        var count = 0
                        metadata: while index < content.endIndex {
                            switch content[index] {
                            case "-":
                                count += 1
                            case "\n":
                                if count == 3 {
                                    break metadata
                                }
                            default:
                                count = 0
                            }
                            index = content.index(after: index)
                        }
                    }
                    let workingString = String(content[index..<content.endIndex]
                        .replacing(/!{|!}|!\[.*\)/, with: ""))
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
