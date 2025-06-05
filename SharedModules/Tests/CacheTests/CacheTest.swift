//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import Testing

@testable import Cache

// verify the static function returns an appropriate URL when called with
// and without a group identifier.

let testDataName = "cachedata"
let testDataExtension = "json"

struct CacheUrlTests {
    @Test func cacheURL() async throws {
        let testCacheFolder = URL.cachesDirectory
        let cacheFileName = testDataName + "." + testDataExtension
        let urlToCacheFile = Cache.cacheURL(name: cacheFileName)
        #expect(urlToCacheFile == testCacheFolder.appending(component: cacheFileName))
    }

    @Test func cacheUrlGroup() async throws {
        let group = "TestGroup"
        let cacheFileName = testDataName + "." + testDataExtension
        let urlToCacheFile = Cache.cacheURL(name: cacheFileName, group: group)
        let regex = #/.*/Containers/Shared/AppGroup/.*/cachedata\.json/#
        _ = try #require(urlToCacheFile.path.wholeMatch(of: regex))
        print("url \(urlToCacheFile) matches")
    }
}

// these tests must be run in sequence to control the existance
// and contents of any existing cache file

@Suite(.serialized)
struct CacheTests {

    func getCache() throws -> Cache {
        let cacheFileName = testDataName + "." + testDataExtension
        let dataURL = Bundle.module.url(forResource: testDataName,
                                        withExtension: testDataExtension)
        let bundleURL = try #require(dataURL)
        let cache = Cache(name: cacheFileName, bundleURL: bundleURL)
        // Cache will abort if the cache could not be created and primed
        return cache
    }

    func removeCache() throws {
        let cache = try getCache()
        let cacheURL = cache.cacheURL
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: cacheURL.path) {
            try fileManager.removeItem(at: cacheURL)
        }
        print("Any existing cache file removed")
    }

    // repeat this test twice.  The first time the cache will be
    // created, the second time the test will use the previously
    // created cache.

    @Test(arguments: [true, false])
    func createCache(arg: Bool) async throws {
        if arg {
            try removeCache()
        }
        let cache = try getCache()
        let names = cache.read(type: [String].self)
        #expect(names.count == 9)
        #expect(names.first == "riders/2025/0302/index.md")
        #expect(names.last == "riders/2025/0209/p-7881.jpg")
    }

    @Test func writeToCache() async throws {
        let newName = "New content"
        let newNameJSON = Data(("[\n\"" + newName + "\"\n]").utf8)
        let cache = try getCache()
        await #expect(throws: Never.self) {
            cache.write(newNameJSON)

            // the above write is performed on a background Task. Give it
            // a chance to finish before reading and verifying the data

            try await Task.sleep(for: .milliseconds(200))
        }
        let names = cache.read(type: [String].self)
        #expect(names.count == 1)
        #expect(names.first == newName)

        // clean up the cache file
        try removeCache()
    }
}
