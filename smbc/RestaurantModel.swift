//
//  RestaurantModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
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
import Combine

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

class RestaurantModel: ObservableObject {
    @Published var restaurants = [Restaurant]()

    private var cancellable: AnyCancellable?

    init(refresh: Bool) {
        let name = "restaurants.json"
        let cache = Cache(name: name, type: [Restaurant].self)
        if refresh {
            cancellable?.cancel()
            let url = URL(string: serverName + name)!
            let cacheUrl = try? cache.fileUrl()
            let downloader = Downloader(url: url, type: [Restaurant].self, cache: cacheUrl)
            cancellable = downloader
                .publisher
                .catch {
                    _ in
                    return Just(cache.cachedData())
                }
                .assign(to: \.restaurants, on: self)
        } else {
            restaurants = cache.cachedData()
        }
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
