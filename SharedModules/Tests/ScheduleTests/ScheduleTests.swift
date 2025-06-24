//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import ASKeys
import Foundation
import SwiftUI
import Testing
import UDF

@testable import Cache
@testable import Schedule

// I had these as separate suites of tests but Xcode wanted to run them
// in parallel which caused race conditions creating/deleting the disk
// cache. Using a test plan with parallel execution off didn't help
// as the running of the various suites was still done in parallel

@MainActor
@Suite(.serialized)
struct ScheduleTests {

    // helper functions

    func removeCache(_ cache: Cache) throws {
        let cacheURL = cache.cacheURL
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: cacheURL.path) {
            try fileManager.removeItem(at: cacheURL)
            print("removed \(cacheURL.path)")
        }
    }

    func createStateWithTestData() -> ScheduleState {
        func bundleURL(for resource: String) -> URL {
            let resourceElements = resource.split(separator: ".")
            let name = String(resourceElements[0])
            let ext = String(resourceElements[1])

            if let url = Bundle.module.url(forResource: name,
                                           withExtension: ext) {
                return url
            }
            fatalError("Missing Bundle Resource: \(resource)")
        }

        let rideURL = bundleURL(for: ScheduleState.rideResource)
        let tripURL = bundleURL(for: ScheduleState.tripResource)
        let restaurantURL = bundleURL(for: ScheduleState.restaurantResource)
        return ScheduleState(noGroup: true,
                             rideURL: rideURL,
                             tripURL: tripURL,
                             restaurantURL: restaurantURL)
    }

    func createStoreWithTestData() -> Store<ScheduleState, ScheduleAction> {
        return Store(initialState: createStateWithTestData(),
                     reduce: ScheduleReducer(),
                     name: "Schedule reducer test store")
    }

    // state tests

    @Test func initState() async throws {
        // prep by blowing away any existing cache
        let cacheState = createStateWithTestData()
        try removeCache(cacheState.rideCache)
        try removeCache(cacheState.tripCache)
        try removeCache(cacheState.restaurantCache)

        // now create a state where the cache should be initialized
        // from data in the test bundle

        let state = createStateWithTestData()
        #expect(state.year == bundleYear)
        #expect(state.loadInProgress == .idle)
        #expect(state.lastFetchError == nil)
        #expect(state.nextRide == nil)

        #expect(state.rideModel.rides.count == 7)
        #expect(state.tripModel.trips.count == 3)
        #expect(state.restaurantModel.restaurants.count == 6)
    }

    @Test func fetchTimes() async throws {
        let state = createStateWithTestData()
        state.updateTimeFetched()
        #expect(state.timeToFetch() == false)

        @AppStorage(ASKeys.scheduleRefreshDate) var refreshDate = Date.distantPast
        refreshDate = Date.now
        #expect(state.timeToFetch() == true)
    }

    // functions not tested
    // - getNextRide
    // - fetchRides(for:)
    // - fetch(year:)

    // Ride Model Tests

    @Test func rideModelProperties() async throws {
        let state = createStateWithTestData()
        #expect(state.rideModel.rides.first?.id == "5/18-elios")
        #expect(state.rideModel.rides.first?.month == 5)
        #expect(state.rideModel.rides.first?.day == 18)
        #expect(state.rideModel.rides.last?.id == "6/22-beachstreet")
    }

    @Test func rideProgression() async throws {
        let state = createStateWithTestData()
        let first = try #require(state.rideModel.rides.first)
        let next = try #require(state.rideModel.ride(following: first))
        #expect(next.id == "5/25-duartes")
        let last = try #require(state.rideModel.rides.last)
        let prev = try #require(state.rideModel.ride(preceding: last))
        #expect(prev.id == "6/15-losgatos")
        let afterTrip = try #require(state.rideModel.ride(following: "6/1"))
        #expect(afterTrip.id == "6/8-giacos")
    }

    @Test func nilRideProgression() async throws {
        let state = createStateWithTestData()
        let first = try #require(state.rideModel.rides.first)
        #expect(state.rideModel.ride(preceding: first) == nil)
        let last = try #require(state.rideModel.rides.last)
        #expect(state.rideModel.ride(following: last) == nil)
        #expect(state.rideModel.ride(following: last.start) == nil)
    }

    // trip model tests

    @Test func tripContent() async throws {
        let state = createStateWithTestData()
        let content = try #require(state.tripModel.trips["Hendy"])
        #expect(content.hasPrefix("Hendy Woods Campout."))
        #expect(content.hasSuffix("west of Boonville."))
    }

    // restaurant model tests

    @Test func restaruantModelContent() async throws {
        let state = createStateWithTestData()
        let first = try #require(state.restaurantModel.restaurants.first)
        #expect(first.id == "beachstreet")
        let last = try #require(state.restaurantModel.restaurants.last)
        #expect(last.id == "losgatos")
    }

    @Test func restaurantFromID() async throws {
        let state = createStateWithTestData()
        let id = "elios"
        let restaurant = state.restaurantModel.restaurant(from: id)
        #expect(restaurant.name == "Elio's Family Restaurant")
    }

    // reducer tests

    @Test func initStore() async throws {
        let store = createStoreWithTestData()
        #expect(store.loadInProgress == .idle)
    }

    @Test func fetchRequested() async throws {
        let store = createStoreWithTestData()
        store.send(.fetchRequested(store.year - 1)) {
            #expect(store.loadInProgress == .loadPending)
        }
        store.send(.fetchRequested(store.year)) {
            #expect(store.loadInProgress == .duplicateLoadPending)
        }
        // Set up to test for not yet time to fetch
        await store.send(.fetchError("reset state"))

        @AppStorage(ASKeys.scheduleRefreshDate) var refreshDate = Date.distantPast
        refreshDate = Date.distantFuture

        store.send(.fetchRequested(store.year)) {
            #expect(store.loadInProgress == .idle)
        }
    }

    @Test func forcedFetchRequested() async throws {
        @AppStorage(ASKeys.scheduleRefreshDate) var refreshDate = Date.distantPast

        let store = createStoreWithTestData()

        // initial and duplicate request
        store.send(.forcedFetchRequested) {
            #expect(store.loadInProgress == .loadPending)
        }
        store.send(.forcedFetchRequested) {
            #expect(store.loadInProgress == .duplicateLoadPending)
        }

        // Simulate a load error
        let fetchError = "Fetch Error"
        store.send(.forcedFetchRequested) {
            #expect(store.loadInProgress == .duplicateLoadPending)
            store.send(.fetchError(fetchError))
        }
        #expect(store.loadInProgress == .idle)
        #expect(store.lastFetchError == fetchError)

        // simulate data received
        let oldRefreshDate = Date.now
        store.send(.forcedFetchRequested) {
            #expect(store.state.loadInProgress == .loadPending)
            store.send(.fetchResults(store.year,
                                     store.rideModel.rides,
                                     store.tripModel.trips,
                                     store.restaurantModel.restaurants))
        }
        #expect(store.loadInProgress == .idle)
        #expect(store.lastFetchError == nil)
        #expect(refreshDate > oldRefreshDate)
    }

    @Test func fetchYearRequested() async throws {
        let store = createStoreWithTestData()
        store.send(.fetchYearRequested(store.year)) {
            #expect(store.loadInProgress == .loadPending)
        }

        let error = "Fetch Error"
        store.send(.fetchYearRequested(store.year)) {
            #expect(store.loadInProgress == .duplicateLoadPending)
            store.send(.fetchError(error))
        }
        #expect(store.loadInProgress == .idle)
        #expect(store.lastFetchError == error)

        let year = store.year
        let rides = store.rideModel.rides
        store.send(.fetchYearRequested(store.year)) {
            #expect(store.loadInProgress == .loadPending)
            store.send(.fetchYearResults(year, rides))
        }
        #expect(store.loadInProgress == .idle)
        #expect(store.lastFetchError == nil)

        let badYear = year + 1
        let badRides: [Ride] = []
        await store.send(.fetchYearResults(badYear, badRides))
        // the above request should have been ignored
        #expect(store.year == year)
        #expect(store.rideModel.rides == rides)
    }

    @Test func nextRide() async throws {
        let store = createStoreWithTestData()
        await store.send(.gotNextRide(store.rideModel.rides.first))
        #expect(store.nextRide == store.rideModel.rides.first)
        await store.send(.clearNextRide)
        #expect(store.nextRide == nil)
        await store.send(.gotNextRide(nil))
        #expect(store.nextRide == nil)
    }
}
