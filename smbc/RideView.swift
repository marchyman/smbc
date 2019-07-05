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


// MARK: - Ride Details

struct RideDetailView: View {
    @EnvironmentObject var smbcData: SMBCData
    @State var ride: ScheduledRide
    let year: String
    
    var body: some View {
        RestaurantDetailView(restaurant: restaurant(id: ride.restaurant!),
                             eta: true)
            .navigationBarTitle(Text("\(ride.start)/\(year) Ride"))
            .navigationBarItems(trailing: Button("Next ride", action: nextRide))
    }
    
    private
    func restaurant(id: String) -> Restaurant {
        return smbcData.idToRestaurant(id: id)
    }
    
    private
    func nextRide() {
        if let next = smbcData.ride(following: ride.start) {
            ride = next
        }
    }
}

// MARK: - RideRow View

struct RideRow: View {
    @EnvironmentObject var smbcData: SMBCData
    var ride: ScheduledRide
    let year: String

    var body: some View {
        NavigationLink(destination: RideDetailView(ride: ride, year: year).environmentObject(smbcData)) {
            HStack () {
                Text(ride.start)
                    .font(.headline)
                    .frame(minWidth: 50, alignment: .leading)
                Text(restaurantName(id: ride.restaurant))
            }
        }
    }
    
    private
    func restaurantName(id: String?) -> String {
        return smbcData.idToRestaurant(id: id).name
    }
}

// MARK: - TripRow View

struct TripRow: View {
    @EnvironmentObject var smbcData: SMBCData
    var ride: ScheduledRide
    
    var body: some View {
        NavigationLink(destination: TripView(ride: ride).environmentObject(smbcData)) {
            HStack () {
                Text("\(ride.start)\n\(ride.end!)")
                    .font(.headline)
                    .lineLimit(2)
                    .frame(minWidth: 50, alignment: .leading)
                Text(ride.description!)
                    .color(.orange)
            }
        }
    }
}

// MARK: - RideView -- list of rides for the year

struct RideView : View {
    @EnvironmentObject var smbcData: SMBCData

    var body: some View {
        List (smbcData.rides) {
            ride in
            if ride.restaurant != nil {
                RideRow(ride: ride, year: self.smbcData.year)
            }
            if ride.end != nil {
                TripRow(ride:ride)
            }
        }.navigationBarTitle(Text("SMBC Rides in \(self.smbcData.year)"))
         .navigationBarItems(trailing: PresentationLink("Change Year",
                                                        destination: PickYear().environmentObject(smbcData)))
    }
}

// MARK: -- Pick a schedule year

/// I don't want to force a fetch of data from the server every time the picker wheel is modified.
/// Better if I wait until the few is about to go away and then cause the model to fetch needed
/// data and signal that the model has changed once the data has been received.
/// Alas, onDisappear is not called for navigation events.  I don't know if that is part of the design
/// or a beta bug.
///
/// I am triggering the update using the done button.  But... button use is optional... the user
/// could swipe the view away, instead.  This is a bug that needs to be resolved.
///
struct PickYear : View {
    @EnvironmentObject var smbcData: SMBCData
    @Environment(\.isPresented) var isPresented: Binding<Bool>

    var body: some View {
        VStack {
            Text("Show the SMBC Ride Schedule for").lineLimit(2)
            Picker(selection: $smbcData.yearIndex,
                   label: Text("Please select a schedule year")) {
                    ForEach(0 ..< smbcData.years.count) {
                        Text(self.smbcData.years[$0]).tag($0)
                    }
            }
            Button("Done") {
                self.smbcData.yearUpdated.toggle()
                self.isPresented?.value.toggle()
            }.padding(.top)
        }
    }
}

#if DEBUG
struct RideView_Previews : PreviewProvider {
    static var previews: some View {
        RideView()
    }
}
#endif
