//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import ASKeys
import Foundation
import SwiftUI
import Testing

@testable import Cache
@testable import Schedule

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

@Suite(.serialized)
struct StateTests {
    func removeCache(_ cache: Cache) throws {
        let cacheURL = cache.cacheURL
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: cacheURL.path) {
            try fileManager.removeItem(at: cacheURL)
        }
    }

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
}

struct RideModelTests {
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
}

struct TripModelTests {
    @Test func tripContent() async throws {
        let state = createStateWithTestData()
        let content = try #require(state.tripModel.trips["Hendy"])
        #expect(content.hasPrefix("Hendy Woods Campout."))
        #expect(content.hasSuffix("west of Boonville."))
    }
}

struct RestaurantModelTests {
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
}
