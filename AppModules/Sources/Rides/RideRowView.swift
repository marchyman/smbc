//
// Copyright 2019 Marco S Hyman
// https://www.snafu.org/
//

import Schedule
import SwiftUI
import UDF

struct RideRowView: View {
    @Environment(Store<ScheduleState, ScheduleAction>.self) var store

    var ride: Ride

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
        return store.restaurantModel.restaurant(from: id).name
    }
}

#Preview {
    RideRowView(ride: Ride(start: "5/7",
                           restaurant: "countryinn",
                           end: nil,
                           description: nil,
                           comment: "Testing"))
        .environment(Store(initialState: ScheduleState(noGroup: true),
                     reduce: ScheduleReducer(),
                     name: "Preview Schedule Store"))

}
