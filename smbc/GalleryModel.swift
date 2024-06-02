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
}

extension String {
    func isJpg() -> Bool {
        return !self.ranges(of: /\.[jJ][pP][eE]?[gG]$/).isEmpty
    }
}
