//
//  RestaurantModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//  Copyright © 2019, 2021 Marco S Hyman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import Foundation

fileprivate let restaurantFileName = "restaurants.json"


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

@MainActor
class RestaurantModel: ObservableObject {
    @Published var restaurants = [Restaurant]()

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
