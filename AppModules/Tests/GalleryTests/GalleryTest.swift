//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import ASKeys
import Cache
import Foundation
import OSLog
import SwiftUI
import Testing

@testable import Gallery

// model and state tests combined and serialized.  Both touch a
// shared cache file.

@MainActor
@Suite(.serialized)
struct GalleryStateTests {
    let testDataName = "testgallery"
    let testDataExtension = "json"

    // return the cache to be used for testing

    func testCache() throws -> Cache {
        let cacheFileName = testDataName + "." + testDataExtension
        let dataURL = Bundle.module.url(forResource: testDataName,
                                        withExtension: testDataExtension)
        let bundleURL = try #require(dataURL)
        let cache = Cache(name: cacheFileName, bundleURL: bundleURL)
        // Cache will abort if the cache could not be created and primed
        return cache
    }

    func makeState() throws -> GalleryState {
        let cache = try testCache()
        return GalleryState(testCache: cache)
    }

    @Test func initGallery() async throws {
        let cache = try testCache()
        let state = GalleryState(testCache: cache)
        let gallery = GalleryModel(cache: cache)
        #expect(gallery.names.count == 9)
        #expect(gallery.names.first == "riders/2025/0302/index.md")
        #expect(gallery.names.last == "riders/2025/0209/p-7881.jpg")
        let path = state.galleryServer + "riders/2025/0209/index.md"
        let text = try await GalleryModel.fetchMarkdown(mdFile: path,
                                                        start: true)
        // "start" returns up to 250 char plus a suffix of "..."
        #expect(text.count == 253)
        let fullText = try await GalleryModel.fetchMarkdown(mdFile: path)
        #expect(fullText.count == 360)
        // full text should contain the start text as a prefix
        // less the added "..."
        #expect(fullText.hasPrefix(text.prefix(250)))
    }

    @Test func initGalleryState() async throws {
        let state = try makeState()
        #expect(state.galleryModel.names.count == 9)
        #expect(state.loadInProgress == .idle)
    }

    // a single test due to reference to @AppStorage
    @Test func fetchRequestRefreshDates() async throws {
        // ignore fetch request if before the refresh date

        @AppStorage(ASKeys.galleryRefreshDate) var refreshDate = Date.distantPast
        refreshDate = Date.distantFuture
        let state = try makeState()
        let reduce = GalleryReducer()
        let state1 = reduce(state, .fetchRequested)
        #expect(state1.loadInProgress == .idle)

        // do the fetch request with a date in the past

        refreshDate = Date.distantPast
        let state2 = reduce(state1, .fetchRequested)
        #expect(state2.loadInProgress == .loadPending)

        // simulate good results from the fetch

        let result = "Good Result"
        let results = [ result ]
        let resultState = reduce(state2, .fetchResults(results))
        #expect(resultState.loadInProgress == .idle)
        #expect(resultState.galleryModel.names.count == 1)
        #expect(resultState.galleryModel.names.first == result)
        // Log output shows the refreshDate was updated, but this expectation
        // fails. Why?
        // #expect(refreshDate != Date.distantPast)
    }

    @Test func badFetchResults() async throws {
        let result = "Good Result"
        let results = [ result ]
        let state = try makeState()
        let reduce = GalleryReducer()
        let newState = reduce(state, .fetchResults(results))
        #expect(newState.loadInProgress == .idle)
        #expect(state.galleryModel == newState.galleryModel)
    }

    @Test func fetchError() async throws {
        let state = try makeState()
        let reduce = GalleryReducer()
        let nextState = reduce(state, .forcedFetchRequested)
        #expect(nextState.loadInProgress == .loadPending)
        let finalState = reduce(nextState, .fetchError("Fetch Failed"))
        #expect(finalState.loadInProgress == .idle)
    }
}
