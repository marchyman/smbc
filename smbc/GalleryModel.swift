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
    var imageNames: [String]

    init() {
        let cache = Cache(name: galleryFileName, type: [String].self)
        imageNames = cache.cachedData()
    }

    func fetch() async throws {
        let url = URL(string: serverName + galleryFileName)!
        imageNames = try await Downloader.fetch(name: galleryFileName,
                                                url: url,
                                                type: [String].self)
    }
}
