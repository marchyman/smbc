//
//  RestaruantView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
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

import SwiftUI

struct RestaurantView : View {
    @EnvironmentObject var restaurantModel: RestaurantModel
    @State private var filter = true
    let active = "Active"
    let all = "All"
    
    var body: some View {
        let buttonTitle: String
        let barTitle: String
        let restaurants: [Restaurant]
        if filter {
            restaurants = restaurantModel.restaurants.filter { $0.status == "open" }
            barTitle = active
            buttonTitle = all
        } else {
            restaurants = restaurantModel.restaurants
            barTitle = all
            buttonTitle = active
        }
        return List (restaurants) {
            restaurant in
            RestaurantRow(restaurant: restaurant)
        }.navigationBarTitle("\(barTitle) Restaurants")
         .navigationBarItems(trailing:
            Button(buttonTitle) { self.filter.toggle() })
    }
}

struct RestaurantRow: View {
    var restaurant: Restaurant
    
    var body: some View {
        var city = restaurant.city
        if restaurant.status != "open" {
            city += " -- \(restaurant.status)"
        }
        return NavigationLink(destination: RestaurantDetailView(restaurant: restaurant,
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
    static var previews: some View {
        RestaurantView()
    }
}
#endif
