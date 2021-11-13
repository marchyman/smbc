//
//  RideVisitsView.swift
//  smbc
//
//  Created by Marco S Hyman on 11/12/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import SwiftUI

struct RideVisitsView: View {
    @EnvironmentObject var state: ProgramState
    @Binding var isActive: Bool
    let restaurant: Restaurant

    var body: some View {
        let filteredRides = state.rideModel.rides.filter {
            $0.restaurant == restaurant.id
        }
        return VStack {
            HStack {
                Spacer()
                Button("Done") {
                    self.isActive = false
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
                List (filteredRides) {
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
    @State static var isShowing = false
    static var previews: some View {
        RideVisitsView(isActive: $isShowing,
                      restaurant: Restaurant(id: "test",
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
