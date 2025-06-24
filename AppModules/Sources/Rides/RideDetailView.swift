//
// Copyright 2019 Marco S Hyman
// https://www.snafu.org/
//

import Restaurants
import Schedule
import SwiftUI
import UDF
import ViewModifiers

struct RideDetailView: View {
    @Environment(Store<ScheduleState, ScheduleAction>.self) var store
    @State var ride: Ride
    @State private var dragOffset: CGSize = .zero
    @State private var firstRide = false
    @State private var lastRide = false

    var body: some View {
        RestaurantDetailView(
            restaurant: store.restaurantModel.restaurant(from: ride.restaurant!),
            eta: true
        )
        .offset(x: dragOffset.width)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    switch value.translation.width {
                    case ...(-100):
                        if ProcessInfo.processInfo.environment["NONEXTRIDE"] != nil {
                            lastRide.toggle()
                        } else if let next = store.rideModel.ride(following: ride) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                ride = next
                            }
                        } else {
                            lastRide.toggle()
                        }
                    case 100...:
                        if ProcessInfo.processInfo.environment["NONEXTRIDE"] != nil {
                            firstRide.toggle()
                        } else if let prev = store.rideModel.ride(preceding: ride) {
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
        .alert("First ride of the year", isPresented: $firstRide) {}
        .alert("Last ride of the year", isPresented: $lastRide) {}
        .navigationTitle("\(ride.start)/\(store.yearString) Ride")
    }
}

#Preview {
    NavigationStack {
        RideDetailView(ride: Ride(start: "5/7",
                                  restaurant: "countryinn",
                                  end: nil,
                                  description: nil,
                                  comment: "Testing"))
            .environment(Store(initialState: ScheduleState(noGroup: true),
                               reduce: ScheduleReducer(),
                               name: "Preview Schedule Store"))
    }
}
