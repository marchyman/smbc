//
//  RestaurantModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//

import Foundation
import Observation

private let restaurantFileName = "restaurants.json"

/// Format of  restaurant records retrieved from server
///
struct Restaurant: Decodable, Identifiable {
    let id: String
    let name: String
    let address: String
    let route: String
    let city: String
    let phone: String
    let status: String
    let eta: String
    let lat: Double
    let lon: Double
}

@Observable
final class RestaurantModel {
    var restaurants = [Restaurant]()

    /// Initialize list of restaurants from the cache
    ///
    init() {
        let cache = Cache(name: restaurantFileName, type: [Restaurant].self)
        restaurants = cache.cachedData()
    }

    /// fetch current data from the server  and update the model.
    ///
    func fetch() async throws {
        let url = URL(string: serverName + restaurantFileName)!
        restaurants = try await Downloader.fetch(
            name: restaurantFileName,
            url: url,
            type: [Restaurant].self
        )
    }

    /// return the restaurant from the restaurants array matching the given id.
    ///
    func idToRestaurant(id: String?) -> Restaurant {
        guard let id = id,
              let restaurant = restaurants.first(where: { $0.id == id }) else {
                fatalError("Missing Restaurant ID")
        }
        return restaurant
    }
}

extension Restaurant: Equatable {
}
