//
// Copyright 2021 Marco S Hyman
// https://www.snafu.org/
//

import Schedule
import SwiftUI
import UDF
import ViewModifiers

struct RestaurantVisitsView: View {
    @Environment(Store<ScheduleState, ScheduleAction>.self) var store
    @Environment(\.dismiss) var dismiss

    let restaurant: Restaurant

    var body: some View {
        let filteredRides = store.state.rideModel.rides.filter {
            $0.restaurant == restaurant.id
        }
        return ZStack {
            Color.clear.smbcBackground()
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }.padding([.top, .horizontal])
                }
                Text(restaurant.name)
                    .font(.title)
                    .padding(.top, 20)
                Text(
                """
                \(rideCountLabel(filteredRides.count))
                scheduled in \(store.state.yearString)
                """
                )
                .padding()
                if filteredRides.isEmpty {
                    Spacer()
                } else {
                    List(filteredRides) { ride in
                        Text(ride.start)
                            .font(.headline)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 50)
                }
            }
        }
    }

    private func rideCountLabel(_ count: Int) -> String {
        if count == 1 {
            return "There is one ride"
        }
        return "There are \(spellOut(count)) rides"
    }

    private func spellOut(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(for: number) ?? ""
    }

}

#Preview {
    RestaurantVisitsView(
        restaurant: Restaurant(
            id: "test",
            name: "Test Restaurant",
            address: "123 Main Street",
            route: "(101/202/303)",
            city: "Some City",
            phone: "(123) 456-7890",
            status: "CLOSED",
            eta: "8:05",
            lat: 37.7244,
            lon: -122.4381)
    )
    .environment(Store(initialState: ScheduleState(),
                       reduce: ScheduleReducer(),
                       name: "Preview Schedule Store"))
}
