//
// Copyright 2019 Marco S Hyman
// https://www.snafu.org/
//

import ASKeys
import Schedule
import SwiftUI
import UDF
import ViewModifiers

public struct RestaurantListView: View {
    @Environment(Store<ScheduleState, ScheduleEvent>.self) var store

    @State private var filter = true

    var title: String {
        (filter ? "Active" : "All") + " Restaurants"
    }
    var filterTitle: String {
        "Show " + (filter ? "All" : "Active")
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            List(filteredRestaurants(filter)) { restaurant in
                RestaurantRow(restaurant: restaurant)
            }
            .listStyle(.insetGrouped)
            .smbcBackground()
            .scrollContentBackground(.hidden)
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

    private func filteredRestaurants(_ filter: Bool) -> [Restaurant] {
        store.restaurantModel.restaurants.filter {
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
       NavigationLink(
           destination: RestaurantDetailView(
               restaurant: restaurant,
               eta: false)
       ) {
            VStack(alignment: .leading) {
                Text(restaurant.name).font(.headline)
                Text(city).font(.subheadline)
            }
       }
    }
}

#Preview {
    RestaurantListView()
        .environment(Store(initialState: ScheduleState(noGroup: true),
                           reduce: ScheduleReducer(),
                           name: "Preview Schedule Store"))
}
