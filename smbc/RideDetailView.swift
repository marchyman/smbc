//
//  RideDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 7/16/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
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

// MARK: - Ride Details

struct RideDetailView: View {
    @EnvironmentObject var restaurantModel: RestaurantModel
    @EnvironmentObject var rideModel: RideModel
    @State var ride: ScheduledRide
    let year: String
    
    var body: some View {
        RestaurantDetailView(restaurant: restaurant(id: ride.restaurant!),
                             eta: true)
            .navigationBarTitle("\(ride.start)/\(year) Ride")
            .navigationBarItems(trailing: Button("Next ride", action: nextRide).disabled(rideModel.ride(following: ride.start) == nil))
    }
    
    private
    func restaurant(id: String) -> Restaurant {
        return restaurantModel.idToRestaurant(id: id)
    }
    
    private
    func nextRide() {
        if let next = rideModel.ride(following: ride.start) {
            ride = next
        }
    }
}

#if DEBUG
struct RideDetailView_Previews : PreviewProvider {
    static var model = Model(savedState: ProgramState.load())

    static var previews: some View {
        RideDetailView(ride: ScheduledRide(start: "5/7",
                                           restaurant: "countryinn",
                                           end: nil,
                                           description: nil,
                                           comment: "Testing"),
                        year: "2019")
            .environmentObject(model.restaurantModel)
            .environmentObject(model.rideModel)
    }
}
#endif
