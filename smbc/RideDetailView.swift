//
//  RideDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 7/16/19.
//

import SwiftUI

struct RideDetailView: View {
    @EnvironmentObject var state: ProgramState
    @State var ride: ScheduledRide

    var body: some View {
        RestaurantDetailView(restaurant: restaurant(id: ride.restaurant!),
                             eta: true)
            .navigationTitle("\(ride.start)/\(state.yearString) Ride")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: nextRide ) {
                        Text("Next ride")
                            .font(.callout)
                    }
                    .disabled(state.rideModel.ride(following: ride.start) == nil)
            }
        }
    }

    private
    func restaurant(id: String) -> Restaurant {
        return state.restaurantModel.idToRestaurant(id: id)
    }

    private
    func nextRide() {
        if let next = state.rideModel.ride(following: ride.start) {
            ride = next
        }
    }
}

#if DEBUG
struct RideDetailView_Previews: PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        NavigationStack {
            RideDetailView(ride: ScheduledRide(start: "5/7",
                                               restaurant: "countryinn",
                                               end: nil,
                                               description: nil,
                                               comment: "Testing"))
            .environmentObject(state)
        }
    }
}
#endif
