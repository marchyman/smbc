//
//  RideRowView.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//

import SwiftUI

struct RideRowView: View {
    @Environment(ProgramState.self) var state
    var ride: ScheduledRide

    var body: some View {
        NavigationLink(destination: RideDetailView(ride: ride)) {
            HStack {
                Text(ride.start)
                    .font(.headline)
                    .frame(minWidth: 50, alignment: .leading)
                Text(restaurantName(id: ride.restaurant))
            }
        }
    }

    private func restaurantName(id: String?) -> String {
        return state.restaurantModel.idToRestaurant(id: id).name
    }
}

#Preview {
    RideRowView(
        ride: ScheduledRide(
            start: "5/7",
            restaurant: "countryinn",
            end: nil,
            description: nil,
            comment: "Testing")
    )
    .environment(ProgramState())

}
