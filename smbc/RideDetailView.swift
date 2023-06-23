//
//  RideDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 7/16/19.
//

import SwiftUI

struct RideDetailView: View {
    @Environment(ProgramState.self) var state
    @State var ride: ScheduledRide
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        RestaurantDetailView(restaurant: restaurant(id: ride.restaurant!),
                             eta: true)
            .offset(x: dragOffset.width)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        dragOffset = .zero
                        switch value.translation.width {
                        case ...(-100):
                            if let next = state.rideModel.ride(following: ride) {
                                ride = next
                            }
                        case 100...:
                            if let prev = state.rideModel.ride(preceding: ride) {
                                ride = prev
                            }
                        default:
                            break
                        }
                    }
            )
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
