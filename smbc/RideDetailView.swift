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
    @State private var firstRide = false
    @State private var lastRide = false

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
                        switch value.translation.width {
                        case ...(-100):
                            if let next = state.rideModel.ride(following: ride) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    ride = next
                                }
                            } else {
                                lastRide.toggle()
                            }
                        case 100...:
                            if let prev = state.rideModel.ride(preceding: ride) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    ride = prev
                                }
                            } else {
                                firstRide.toggle()
                            }
                        default:
                            break
                        }
                        dragOffset = .zero
                    }
            )
            .alert("First ride of the year", isPresented: $firstRide) { }
            .alert("Last ride of the year", isPresented: $lastRide) { }
            .navigationTitle("\(ride.start)/\(state.scheduleYearString) Ride")
    }

    private func restaurant(id: String) -> Restaurant {
        return state.restaurantModel.idToRestaurant(id: id)
    }
}

#Preview {
    NavigationStack {
        RideDetailView(ride: ScheduledRide(start: "5/7",
                                           restaurant: "countryinn",
                                           end: nil,
                                           description: nil,
                                           comment: "Testing"))
            .environment(ProgramState())
    }
}
