//
//  RestaruantView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
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

import SwiftUI

struct RestaurantView : View {
    @EnvironmentObject var state: ProgramState
    @State private var filter = true
    var title: String {
        (filter ? "Active" : "All") + " Restaurants"
    }
    var filterTitle: String {
        "Show " + (filter ? "All" : "Active")
    }

    var body: some View {
        List (filteredRestaurants(filter)) { restaurant in
            RestaurantRow(restaurant: restaurant)
        }
        .navigationBarTitle(title)
        .navigationBarItems(
            trailing: Button(filterTitle) { self.filter.toggle() }
        )
    }

    private
    func filteredRestaurants(_ filter: Bool) -> [Restaurant] {
        state.restaurantModel.restaurants.filter {
            !filter || $0.status == "open" || $0.status.hasPrefix("was ")
        }
    }
}

struct RestaurantRow: View {
    var restaurant: Restaurant
    var city: String {
        if restaurant.status != "open" {
            return restaurant.city + " -- \(restaurant.status)"
        }
        return restaurant.city
    }
    var body: some View {
        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant,
                                                         eta: false)) {
            VStack (alignment: .leading) {
                Text(restaurant.name).font(.headline)
                Text(city).font(.subheadline)
            }
        }
    }
}

#if DEBUG
struct RestaurantView_Previews : PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        NavigationView {
            RestaurantView()
                .environmentObject(state)
        }
    }
}
#endif
