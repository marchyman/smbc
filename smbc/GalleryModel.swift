//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import Foundation

private let galleryFileName = "gallery.json"

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
        names = try await Downloader.fetch(name: galleryFileName,
                                                url: url,
                                                type: [String].self)
    }

    nonisolated func fetch(mdFile name: String) async throws -> String {
        var content: String = ""
        if let url = URL(string: serverName + name) {
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration,
                                     delegate: nil, delegateQueue: nil)
            do {
                let (data, _) = try await session.data(from: url)
                content = String(decoding: data, as: UTF8.self)
            }
        }
        return content
    }
}

extension String {
    func isJpg() -> Bool {
        return !self.ranges(of: /\.[jJ][pP][eE]?[gG]$/).isEmpty
    }
}
