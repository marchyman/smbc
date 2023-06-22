//
//  RestaurantDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
//

import SwiftUI
import MapKit

/// Restaurant detail view.
///
/// This view is used when a restaurant is sellect for the list of restaurants and when a Sunday morning
/// ride is selected from the rides list.
struct RestaurantDetailView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(ProgramState.self) var state
    @State private var showVisits = false

    let restaurant: Restaurant
    let eta: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack {
                RestaurantInfoView(restaurant: restaurant, eta: eta)
                    .frame(minHeight: 0, maxHeight: geometry.size.height * 0.35)
                RestaurantMapView(restaurant: restaurant)
            }
            .background(backgroundGradient(colorScheme))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    showVisitButton
                }
            }
        }
    }

    var showVisitButton: some View {
        Button("Show Visits") {
            showVisits = true
        }
        .sheet(isPresented: $showVisits) {
            RideVisitsView(restaurant: restaurant)
        }
    }

}

#Preview {
    let state = ProgramState()

    return NavigationStack {
        RestaurantDetailView(restaurant: Restaurant(id: "beachstreet",
                                                    name: "Beach Street",
                                                    address: "435 W. Beach Street",
                                                    route: "101/92/280/85/17/1",
                                                    city: "Watsonville",
                                                    phone: "831-722-2233",
                                                    status: "open",
                                                    eta: "8:17",
                                                    lat: 37.113013,
                                                    lon: -121.637845),
                             eta: false)
        .environment(state)
    }
}
