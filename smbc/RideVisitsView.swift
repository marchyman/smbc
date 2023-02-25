//
//  RideVisitsView.swift
//  smbc
//
//  Created by Marco S Hyman on 11/12/21.
//

import SwiftUI

struct RideVisitsView: View {
    @EnvironmentObject var state: ProgramState
    @Environment(\.dismiss) var dismiss

    let restaurant: Restaurant

    var body: some View {
        let filteredRides = state.rideModel.rides.filter {
            $0.restaurant == restaurant.id
        }
        return VStack {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }.padding()
            }
            Text(restaurant.name)
                .font(.title)
                .padding(.top, 40)
            Text("""
                 \(rideCountLabel(filteredRides.count))
                 scheduled in \(state.yearString)
                 """)
                .padding()
            if filteredRides.isEmpty {
                Spacer()
            } else {
                List(filteredRides) {
                    ride in
                    Text(ride.start)
                        .font(.headline)
                }.padding()
            }
        }
    }

    private
    func rideCountLabel(_ count: Int) -> String {
        if count == 1 {
            return "There is one ride"
        }
        return "There are \(spellOut(count)) rides"
    }

    private
    func spellOut(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(for: n) ?? ""
    }

}

#if DEBUG
struct RideVisitsView_Previews: PreviewProvider {
    static var state = ProgramState()
    static var previews: some View {
        RideVisitsView(restaurant: Restaurant(id: "test",
                                           name: "Test Restaurant",
                                           address: "123 Main Street",
                                           route: "(101/202/303)",
                                           city: "Some City",
                                           phone: "(123) 456-7890",
                                           status: "CLOSED",
                                           eta: "8:05",
                                           lat: 37.7244,
                                           lon: -122.4381))
            .environmentObject(state)
    }
}
#endif
