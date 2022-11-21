//
//  MapInfoView.swift
//  smbc
//
//  Created by Marco S Hyman on 11/10/21.
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
import MapKit

struct MapInfoView: View {
    @EnvironmentObject var state: ProgramState

    let types = [MKMapType.standard, MKMapType.satellite, MKMapType.hybrid]

    let restaurant: Restaurant

    var body: some View {
        // put a segmented control to pick the desired map type
        // on top of the map
        ZStack(alignment: .top) {
            MapView(mapType: types[state.mapTypeIndex],
                    center: CLLocationCoordinate2D(latitude: restaurant.lat,
                                                   longitude: restaurant.lon))
            Picker("", selection: $state.mapTypeIndex) {
                ForEach(0 ..< types.count, id: \.self) {
                    index in
                    Text(types[index].name).tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
             .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.5)))
             .padding(.horizontal)
        }
    }
}

struct MapInfoView_Previews: PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        MapInfoView(restaurant: Restaurant(id: "test",
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
