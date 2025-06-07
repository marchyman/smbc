//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import ASKeys
import Foundation
import SwiftUI
import Testing
import UDF

@testable import Schedule

@MainActor
func createStoreWithTestData() -> Store<ScheduleState, ScheduleAction> {
    return Store(initialState: createStateWithTestData(),
                 reduce: ScheduleReducer(),
                 name: "Schedule reducer test store")
}

@MainActor
@Suite(.serialized)
struct ReducerTests {
    @Test func initStore() async throws {
        let store = createStoreWithTestData()
        #expect(store.state.loadInProgress == .idle)
    }

    @Test func fetchRequested() async throws {
        let store = createStoreWithTestData()
        store.send(.fetchRequested(store.state.year - 1)) {
            #expect(store.state.loadInProgress == .loadPending)
        }
        store.send(.fetchRequested(store.state.year)) {
            #expect(store.state.loadInProgress == .duplicateLoadPending)
        }
        // Set up to test for not yet time to fetch
        await store.send(.fetchError("reset state"))

        @AppStorage(ASKeys.scheduleRefreshDate) var refreshDate = Date.distantPast
        refreshDate = Date.distantFuture

        store.send(.fetchRequested(store.state.year)) {
            #expect(store.state.loadInProgress == .idle)
        }
    }

    @Test func forcedFetchRequested() async throws {
        @AppStorage(ASKeys.scheduleRefreshDate) var refreshDate = Date.distantPast

        let store = createStoreWithTestData()

        // initial and duplicate request
        store.send(.forcedFetchRequested) {
            #expect(store.state.loadInProgress == .loadPending)
        }
        store.send(.forcedFetchRequested) {
            #expect(store.state.loadInProgress == .duplicateLoadPending)
        }

        // Simulate a load error
        let fetchError = "Fetch Error"
        store.send(.forcedFetchRequested) {
            #expect(store.state.loadInProgress == .duplicateLoadPending)
            store.send(.fetchError(fetchError))
        }
        #expect(store.state.loadInProgress == .idle)
        #expect(store.state.lastFetchError == fetchError)

        // simulate data received
        let oldRefreshDate = Date.now
        store.send(.forcedFetchRequested) {
            #expect(store.state.loadInProgress == .loadPending)
            store.send(.fetchResults(store.state.year,
                                     store.state.rideModel.rides,
                                     store.state.tripModel.trips,
                                     store.state.restaurantModel.restaurants))
        }
        #expect(store.state.loadInProgress == .idle)
        #expect(store.state.lastFetchError == nil)
        #expect(refreshDate > oldRefreshDate)
    }

    @Test func fetchYearRequested() async throws {
        let store = createStoreWithTestData()
        store.send(.fetchYearRequested(store.state.year)) {
            #expect(store.state.loadInProgress == .loadPending)
        }

        let error = "Fetch Error"
        store.send(.fetchYearRequested(store.state.year)) {
            #expect(store.state.loadInProgress == .duplicateLoadPending)
            store.send(.fetchError(error))
        }
        #expect(store.state.loadInProgress == .idle)
        #expect(store.state.lastFetchError == error)

        let year = store.state.year
        let rides = store.state.rideModel.rides
        store.send(.fetchYearRequested(store.state.year)) {
            #expect(store.state.loadInProgress == .loadPending)
            store.send(.fetchYearResults(year, rides))
        }
        #expect(store.state.loadInProgress == .idle)
        #expect(store.state.lastFetchError == nil)

        let badYear = year + 1
        let badRides: [Ride] = []
        await store.send(.fetchYearResults(badYear, badRides))
        // the above request should have been ignored
        #expect(store.state.year == year)
        #expect(store.state.rideModel.rides == rides)
    }

    @Test func nextRide() async throws {
        let store = createStoreWithTestData()
        await store.send(.gotNextRide(store.state.rideModel.rides.first))
        #expect(store.state.nextRide == store.state.rideModel.rides.first)
        await store.send(.clearNextRide)
        #expect(store.state.nextRide == nil)
        await store.send(.gotNextRide(nil))
        #expect(store.state.nextRide == nil)
    }
}
