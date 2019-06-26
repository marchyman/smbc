//
//  RideView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
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

// MARK: - RideRow View

struct RideRow: View {
    @EnvironmentObject var smbcData: SMBCData
    var ride: ScheduledRide
    
    var body: some View {
        NavigationButton(destination: RestaurantDetailView(restaurant: idToRestaurant(id: ride.restaurant))) {
            HStack () {
                Text(ride.start)
                    .font(.headline)
                    .frame(minWidth: 50, alignment: .leading)
                Text(restaurantName(id: ride.restaurant))
            }
        }
    }

    private
    func idToRestaurant(id: String?) -> Restaurant {
        guard let id = id, let restaurant =
            smbcData.restaurants.first(where: { $0.id == id }) else {
                fatalError("Missing Restaurant ID")
        }
        return restaurant
    }
    
    private
    func restaurantName(id: String?) -> String {
        return idToRestaurant(id: id).name
    }
}

// MARK: - TripRow View

struct TripRow: View {
    var ride: ScheduledRide
    
    var body: some View {
        //        return NavigationButton(destination: RestaurantDetailView(restaurant: restaurant)) {
        HStack () {
            Text("\(ride.start)\n\(ride.end!)")
                .font(.headline)
                .lineLimit(2)
                .frame(minWidth: 50, alignment: .leading)
            Text(ride.description!)
        }
        //        }
    }
}

// MARK: - RideView -- list of rides for the year

struct RideView : View {
    @EnvironmentObject var smbcData: SMBCData
    var body: some View {
        List (smbcData.rides) {
            ride in
            if ride.restaurant != nil {
                RideRow(ride: ride)
            }
            if ride.end != nil {
                TripRow(ride:ride)
            }
        }.navigationBarTitle(Text(navTitle()))
    }
    
    private
    func navTitle() -> String {
        let yearFormat = DateFormatter()
        yearFormat.dateFormat = "y"
        let year = yearFormat.string(from: Date())
        return "SMBC Rides in \(year)"
    }
}

#if DEBUG
struct RideView_Previews : PreviewProvider {
    static var previews: some View {
        RideView()
    }
}
#endif
