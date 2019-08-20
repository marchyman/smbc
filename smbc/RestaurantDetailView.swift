//
//  RestaurantDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
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
import MapKit

/// Restaurant detail view.
///
/// This view is used when a restaurant is sellect for the list of restaurants and when a Sunday morning
/// ride is selected from the rides list.
struct RestaurantDetailView : View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject var rideModel: RideModel
    @State private var selectorIndex = 0
    @State private var showVisits = false
    let types = [MKMapType.standard, MKMapType.satellite, MKMapType.hybrid]
    let restaurant: Restaurant
    let eta: Bool

    var sheet: some View {
        let filteredRides = rideModel.rides.filter { $0.restaurant == restaurant.id }
        return VStack {
            if filteredRides.count == 1 {
                Text("There is one ride to")
                    .padding(.top, 40)
            } else {
                Text("There are \(spellOut(filteredRides.count)) rides to")
                    .padding(.top, 40)
            }
            Text(restaurant.name)
                .font(.title)
                .padding()
            Text("scheduled in \(rideModel.rideYear)")
 
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

    var body: some View {
        VStack {
            Text(restaurant.name)
                .font(.title)
                .padding(.bottom)
            if restaurant.status != "open" {
                Text(restaurant.status)
                    .italic()
                    .font(.footnote)
                    .offset(x: 0, y: -20)
            }
            Text(restaurant.address)
            Text(restaurant.city)
            Text(restaurant.phone)
            if eta {
                HStack {
                    Text("Route: \(restaurant.route)")
                    Spacer()
                    Text("ETA: \(restaurant.eta)")
                }.padding([.top, .leading, .trailing])
            } else {
                Text(restaurant.route).padding(.top)
            }
            // put a segmented control to pick the desired map type
            // on top of the map
            ZStack(alignment: .top) {
                MapView(mapType: types[selectorIndex],
                        center: CLLocationCoordinate2D(latitude: restaurant.lat,
                                                       longitude: restaurant.lon))
//                Picker("", selection: $selectorIndex) {
//                    ForEach(0 ..< types.count) {
//                        index in
//                        Text(self.types[index].name).tag(index)
//                    }
//                }.pickerStyle(SegmentedPickerStyle())
//                 .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.5)))
//                 .padding(.horizontal)
            }
        }.frame(minWidth: 0, maxWidth: .infinity,
                minHeight: 0, maxHeight: .infinity)
         .background(backgroundGradient(colorScheme))
         .navigationBarItems(trailing: Button("Show visits") { self.showVisits = true})
         .sheet(isPresented: $showVisits, onDismiss: { }) { self.sheet }
        
    }
    
    private
    func spellOut(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(for: n) ?? ""
    }
}

#if DEBUG
struct RestaurantDetailView_Previews : PreviewProvider {
    static var model = Model(savedState: ProgramState.load())

    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant(id: "test",
                                                    name: "Test Restaurant",
                                                    address: "123 Main Street",
                                                    route: "(101/202/303)",
                                                    city: "Some City",
                                                    phone: "(123) 456-7890",
                                                    status: "CLOSED",
                                                    eta: "8:05",
                                                    lat: 37.7244,
                                                    lon: -122.4381),
                             eta: false)
            .environmentObject(model.rideModel)
    }
}
#endif
