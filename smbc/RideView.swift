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

// MARK: - RideView -- list of rides for the year

struct RideView : View {
    @EnvironmentObject var rideModel: RideModel
    @State private var yearPickerPresented = false

    var alert: Alert {
        Alert(title: Text("Schedule access error"),
              message: Text("""
                Schedule data for the desired year is not availalbe at this time.  There may be a network or server issue.

                Please try again, later.
                """),
              dismissButton: .default(Text("OK")))
    }

    var sheet: some View {
        VStack {
            Picker("Pick desired year",
                   selection: $rideModel.programState.selectedIndex) {
                ForEach(0 ..< rideModel.programState.scheduleYears.count) {
                    Text(self.rideModel.programState.scheduleYears[$0].year).tag($0)
                }
            }.pickerStyle(WheelPickerStyle())
             .labelsHidden()
            Text("Pick desired year")
            Text("Swipe down to return to schedule").padding()
            Spacer()
        }
    }

    var body: some View {
        VStack {
            List (rideModel.rides) {
                ride in
                if ride.restaurant != nil {
                    RideRow(ride: ride, year: self.rideModel.rideYear)
                }
                if ride.end != nil {
                    TripRow(ride:ride)
                }
            }
            NavigationLink("Show next ride",
                           destination: RideDetailView(ride: rideModel.nextRide!,
                                                       year: self.rideModel.rideYear))
                .disabled(rideModel.nextRide == nil)
                .font(.title)
                .padding(.bottom)
        }.navigationBarTitle("SMBC Rides in \(self.rideModel.rideYear)")
         .navigationBarItems(trailing: Button("Change year") { self.yearPickerPresented = true })
         .sheet(isPresented: $yearPickerPresented,
                onDismiss: rideModel.fetchRideData) { self.sheet }
         .alert(isPresented: $rideModel.fileUnavailable) { alert }
    }
}

// MARK: - RideRow View

struct RideRow: View {
    @EnvironmentObject var restaurantModel: RestaurantModel
    var ride: ScheduledRide
    let year: String
    
    var body: some View {
        NavigationLink(destination: RideDetailView(ride: ride, year: year)) {
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
        return restaurantModel.idToRestaurant(id: id).name
    }
}


// MARK: - TripRow View

struct TripRow: View {
    var ride: ScheduledRide
    
    var body: some View {
        NavigationLink(destination: TripDetailView(ride: ride)) {
            HStack () {
                Text("\(ride.start)\n\(ride.end!)")
                    .font(.headline)
                    .lineLimit(2)
                    .frame(minWidth: 50, alignment: .leading)
                Text(ride.description!)
                    .foregroundColor(.orange)
            }
        }
    }
}

#if DEBUG
struct RideView_Previews : PreviewProvider {
    static var model = Model(savedState: ProgramState.load())

    static var previews: some View {
        RideView()
            .environmentObject(model.rideModel)
            .environmentObject(model.restaurantModel)
    }
}
#endif
