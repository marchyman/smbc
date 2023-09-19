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
                Text(tripDates())
                    .font(.headline)
                    .lineLimit(2)
                    .frame(minWidth: 50, alignment: .leading)
                Text(ride.description!)
                    .foregroundColor(.orange)
            }
        }
    }

    private func tripDates() -> String {
        if let end = ride.end {
            return "\(ride.start)\n\(end)"
        }
        return "\(ride.start)"
    }
}

#Preview {
    TripRowView(ride: ScheduledRide(start: "5/7",
                                    restaurant: nil,
                                    end: "5/9",
                                    description: "A ride to somewhere",
                                    comment: "Testing"))
}

#Preview {
    TripRowView(ride: ScheduledRide(start: "5/7",
                                    restaurant: nil,
                                    end: nil,
                                    description: "A day ride",
                                    comment: "Testing"))
}
