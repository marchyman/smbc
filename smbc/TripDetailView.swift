//
//  TripView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/27/19.
//

import SwiftUI

struct TripDetailView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    var ride: ScheduledRide

    var body: some View {
        VStack {
            Text(tripText())
                .lineLimit(nil)
                .padding()
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity,
                minHeight: 0, maxHeight: .infinity)
         .background(backgroundGradient(colorScheme))
         .navigationTitle(tripTitle())
         .navigationBarTitleDisplayMode(.inline)
    }

    private func tripText() -> String {
        if let spaceIndex = ride.description?.firstIndex(of: " ") {
            let key = String(ride.description![..<spaceIndex])
            if let trip = state.tripModel.trips[key] {
                return trip
            }

        }
        return """
            Sorry!

            I don't have any information about
            \(ride.description!)
            """
    }

    private func tripTitle() -> String {
        if let end = ride.end {
            return "\(ride.start) - \(end), \(state.scheduleYearString)"
        }
        return "\(ride.start), \(state.scheduleYearString)"
    }
}

#Preview {
    NavigationStack {
        TripDetailView(ride: ScheduledRide(start: "7/12",
                                           restaurant: nil,
                                           end: "7/13",
                                           description: "Camping blah",
                                           comment: "preview"))
            .environment(ProgramState())
     }
}

#Preview {
    NavigationStack {
        TripDetailView(ride: ScheduledRide(start: "8/24",
                                           restaurant: nil,
                                           end: nil,
                                           description: "Boot Dinner",
                                           comment: "preview"))
            .environment(ProgramState())
     }
}

#Preview {
    NavigationStack {
        TripDetailView(ride: ScheduledRide(start: "8/24",
                                           restaurant: nil,
                                           end: nil,
                                           description: "unknown trip",
                                           comment: "preview"))
            .environment(ProgramState())
     }
}
