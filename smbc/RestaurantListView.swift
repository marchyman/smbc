//
//  RestaruantListView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
//

import SwiftUI

struct RestaurantListView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var filter = true
    var title: String {
        (filter ? "Active" : "All") + " Restaurants"
    }
    var filterTitle: String {
        "Show " + (filter ? "All" : "Active")
    }

    var body: some View {
        NavigationStack {
            List(filteredRestaurants(filter)) { restaurant in
                RestaurantRow(restaurant: restaurant)
            }
            .background(backgroundGradient(colorScheme))
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
    }

    @MainActor
    private func filteredRestaurants(_ filter: Bool) -> [Restaurant] {
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

#Preview {
    NavigationStack {
        RestaurantListView()
            .environment(ProgramState())
    }
}
