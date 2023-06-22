//
//  TripRowView.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//
import SwiftUI

struct TripRowView: View {
    var ride: ScheduledRide

    var body: some View {
        NavigationLink(destination: TripDetailView(ride: ride)) {
            HStack {
                Text("\(ride.start)\n\(ride.end!)")
                    .font(.headline)
                    .lineLimit(2)
                    .frame(minWidth: 50, alignment: .leading)
                Text(ride.description!)
                    .foregroundColor(.orange)
            }
        }
    }
}

#Preview {
    let state = ProgramState()

    return TripRowView(ride: ScheduledRide(start: "5/7",
                                           restaurant: nil,
                                           end: "5/9",
                                           description: "A ride to somewhere",
                                           comment: "Testing"))
        .environment(state)
}
