//
// Copyright 2019 Marco S Hyman
// https://www.snafu.org/
//

import Schedule
import SwiftUI
import UDF
struct TripDetailView: View {
    @Environment(Store<ScheduleState, ScheduleEvent>.self) var store

    var ride: Ride

    var body: some View {
        VStack {
            Text(tripText())
                .lineLimit(nil)
                .padding()
            Spacer()
        }.frame(
            minWidth: 0, maxWidth: .infinity,
            minHeight: 0, maxHeight: .infinity
        )
        .smbcBackground()
        .navigationTitle(tripTitle())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tripText() -> String {
        if let spaceIndex = ride.description?.firstIndex(of: " ") {
            let key = String(ride.description![..<spaceIndex])
            if let trip = store.tripModel.trips[key] {
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
            return "\(ride.start) - \(end), \(store.yearString)"
        }
        return "\(ride.start), \(store.yearString)"
    }
}

#Preview {
    NavigationStack {
        TripDetailView(ride: Ride(start: "7/12",
                                  restaurant: nil,
                                  end: "7/13",
                                  description: "Camping blah",
                                  comment: "preview"))
            .environment(Store(initialState: ScheduleState(noGroup: true),
                               reduce: ScheduleReducer(),
                               name: "Preview Schedule Store"))
    }
}

#Preview {
    NavigationStack {
        TripDetailView(ride: Ride(start: "8/24",
                                  restaurant: nil,
                                  end: nil,
                                  description: "Boot Dinner",
                                  comment: "preview"))
        .environment(Store(initialState: ScheduleState(noGroup: true),
                           reduce: ScheduleReducer(),
                           name: "Preview Schedule Store"))
    }
}

#Preview {
    NavigationStack {
        TripDetailView(ride: Ride(start: "8/24",
                                  restaurant: nil,
                                  end: nil,
                                  description: "unknown trip",
                                  comment: "preview"))
        .environment(Store(initialState: ScheduleState(noGroup: true),
                           reduce: ScheduleReducer(),
                           name: "Preview Schedule Store"))
    }
}
