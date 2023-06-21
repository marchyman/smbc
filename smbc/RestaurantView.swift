//
//  RestaruantView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
//

import SwiftUI

struct RestaurantView: View {
    @EnvironmentObject var state: ProgramState
    @State private var filter = true
    var title: String {
        (filter ? "Active" : "All") + " Restaurants"
    }
    var filterTitle: String {
        "Show " + (filter ? "All" : "Active")
    }

    var body: some View {
        List(filteredRestaurants(filter)) { restaurant in
            RestaurantRow(restaurant: restaurant)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    filter.toggle()
                } label: {
                    Text(filterTitle)
                        .font(.callout)
                }
            }
        }
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
            VStack(alignment: .leading) {
                Text(restaurant.name).font(.headline)
                Text(city).font(.subheadline)
            }
        }
    }
}

#if DEBUG
struct RestaurantView_Previews: PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        NavigationStack {
            RestaurantView()
                .environmentObject(state)
        }
    }
}
#endif
