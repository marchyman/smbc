//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import Testing

@testable import Downloader

@Test func downloaderInitAndError() async throws {
    // create a downloader
    let url = URL(string: "http://none.snafu.org/testfile")!
    let downloader = Downloader(url, cache: nil, decodeType: String.self)
    // Expect an error trying to fetch JSON from a server that doesn't exist
    let error = await #expect(throws: URLError.self) {
        _ = try await downloader.fetchJSON()
    }
    #expect(error?.localizedDescription == "A server with the specified hostname could not be found.")
}
