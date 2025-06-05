//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Cache
import Foundation
import OSLog
import Testing

@testable import Restaurants

let testRestaurant = Restaurant(
        id: "beachstreet",
        name: "Beach Street",
        address: "435 W. Beach Street",
        route: "101/92/280/85/17/1",
        city: "Watsonville",
        phone: "831-722-2233",
        status: "open",
        eta: "8:17",
        lat: 36.906514,
        lon: -121.764811
    )

struct RestaurantsModelTests {
    @Test func initRestaurants() async throws {
        let restaurants = RestaurantsModel()
        #expect(restaurants.list.count == 57)
        let restaurant = restaurants.restaurant(by: testRestaurant.id)
        #expect(restaurant == testRestaurant)
    }

    @Test func restaurantsCacheURL() async throws {
        let restaurants = RestaurantsModel()
        let cacheFileName = restaurants.resourceName  + "." + restaurants.resourceExtension
        let cacheURL = Cache.cacheURL(name: cacheFileName)
        #expect(restaurants.cacheURL == cacheURL)
    }

    @Test func restaurantsBundleURL() async throws {
        let restaurants = RestaurantsModel()
        Logger().notice("bundleURL = \(restaurants.bundleURL, privacy: .public)")
        // the above either works or dies with a fatalError
    }
}

struct RestaurantsStateTests {
    @Test func initRestaurantsState() async throws {
        let state = RestaurantsState()
        #expect(state.restaurants.list.count == 57)
        #expect(state.loadInProgress == false)
    }
}

struct RestaurantsReducerTests {

    @Test func fetchRequest() async throws {
        let state = RestaurantsState()
        let reducer = RestaurantsReducer()
        let newState = reducer.reduce(state, .restaurantsFetchRequested)
        #expect(newState.loadInProgress == true)
    }

    @Test func goodFetchResults() async throws {
        let results = [ testRestaurant ]
        let state = RestaurantsState()
        let reduce = RestaurantsReducer()
        // uses RestaurantsReducer callAsFunction
        let workingState = reduce(state, .restaurantsFetchRequested)
        let newState = reduce(workingState, .restaurantsFetchResults(results))
        #expect(newState.loadInProgress == false)
        #expect(newState.restaurants.list.count == 1)
        #expect(newState.restaurants.restaurant(by: testRestaurant.id) == testRestaurant)
    }

    @Test func badFetchResults() async throws {
        let results = [ testRestaurant ]
        let state = RestaurantsState()
        let reduce = RestaurantsReducer()
        // uses RestaurantsReducer callAsFunction
        // results without first requesting a fetch should be ignored
        let newState = reduce(state, .restaurantsFetchResults(results))
        #expect(newState.loadInProgress == false)
        #expect(state.restaurants == newState.restaurants)
    }
}
