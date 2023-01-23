//
//  RideDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 7/16/19.
//  Copyright © 2019, 2021 Marco S Hyman. All rights reserved.
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

struct RideDetailView: View {
    @EnvironmentObject var state: ProgramState
    @State var ride: ScheduledRide

    var body: some View {
        RestaurantDetailView(restaurant: restaurant(id: ride.restaurant!),
                             eta: true)
            .navigationTitle("\(ride.start)/\(state.yearString) Ride")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: nextRide) {
                    Text("Next ride")
                        .font(.callout)
                }


                            .disabled(state.rideModel.ride(following: ride.start) == nil))
    }
    
    private
    func restaurant(id: String) -> Restaurant {
        return state.restaurantModel.idToRestaurant(id: id)
    }
    
    private
    func nextRide() {
        if let next = state.rideModel.ride(following: ride.start) {
            ride = next
        }
    }
}

#if DEBUG
struct RideDetailView_Previews : PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        RideDetailView(ride: ScheduledRide(start: "5/7",
                                           restaurant: "countryinn",
                                           end: nil,
                                           description: nil,
                                           comment: "Testing"))
            .environmentObject(state)
    }
}
#endif
