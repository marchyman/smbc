//
//  MapInfoView.swift
//  smbc
//
//  Created by Marco S Hyman on 11/10/21.
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
