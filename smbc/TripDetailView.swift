//
//  TripView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/27/19.
//

import Foundation
import SwiftUI

struct TripDetailView: View {
    @EnvironmentObject var state: ProgramState
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
         .navigationTitle("\(ride.start) - \(ride.end!) Trip")
         .navigationBarTitleDisplayMode(.inline)
    }
    
    private
    func tripText() -> String {
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
}

#if DEBUG
struct tripView_Previews : PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        NavigationStack {
            TripDetailView(ride: ScheduledRide(start: "7/12",
                                               restaurant: nil,
                                               end: "7/13",
                                               description: "Camping blah",
                                               comment: "preview"))
            .environmentObject(state)
        }
    }
}
#endif
