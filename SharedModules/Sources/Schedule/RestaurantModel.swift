//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Cache
import Foundation

// Format of  restaurant records retrieved from server

public struct Restaurant: Decodable, Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let address: String
    public let route: String
    public let city: String
    public let phone: String
    public let status: String
    public let eta: String
    public let lat: Double
    public let lon: Double

    public init(id: String, name: String, address: String, route: String,
                city: String, phone: String, status: String, eta: String,
                lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.route = route
        self.city = city
        self.phone = phone
        self.status = status
        self.eta = eta
        self.lat = lat
        self.lon = lon
    }
}

public struct RestaurantModel: Equatable, Sendable {
    public var restaurants: [Restaurant]

    public init(cache: Cache) {
        restaurants = cache.read(type: [Restaurant].self)
    }
}

// restaurant look up function

extension RestaurantModel {

    // return the restaurant from the restaurants array matching the given id.

    public func restaurant(from id: String?) -> Restaurant {
        guard let id = id,
            let restaurant = restaurants.first(where: { $0.id == id })
        else {
            fatalError("Missing Restaurant ID")
        }
        return restaurant
    }
}
