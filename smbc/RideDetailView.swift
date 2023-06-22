//
//  RideDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 7/16/19.
//

import SwiftUI

struct RideDetailView: View {
    @Environment(ProgramState.self) var state
    var ride: ScheduledRide

    var body: some View {
        RestaurantDetailView(restaurant: restaurant(id: ride.restaurant!),
                             eta: true)
            .navigationTitle("\(ride.start)/\(state.scheduleYearString) Ride")
    }

    private
    func restaurant(id: String) -> Restaurant {
        return state.restaurantModel.idToRestaurant(id: id)
    }
}

#Preview {
    let state = ProgramState()

    return NavigationStack {
        RideDetailView(ride: ScheduledRide(start: "5/7",
                                           restaurant: "countryinn",
                                           end: nil,
                                           description: nil,
                                           comment: "Testing"))
            .environment(state)
    }
}
