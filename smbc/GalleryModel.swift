//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import Foundation

@MainActor
@Observable
final class GalleryModel {
    var names: [String]

    init() {
        let cache = Cache(name: galleryFileName, type: [String].self)
        names = cache.cachedData()
    }
}

extension GalleryModel {
    func fetch() async throws {
        let url = URL(string: serverName + galleryFileName)!
        names = try await Downloader.fetch(
            name: galleryFileName,
            url: url,
            type: [String].self)
    }

    nonisolated static func fetch(
        mdFile name: String,
        start: Bool = false
    ) async throws -> String {
        if let url = URL(string: serverName + name) {
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

extension String {
    func endsInJpg() -> Bool {
        return !self.ranges(of: /\.[jJ][pP][eE]?[gG]$/).isEmpty
    }
}
