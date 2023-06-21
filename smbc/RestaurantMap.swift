//
//  RestaurantMap.swift
//  smbc
//
//  Created by Marco S Hyman on 1/23/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import SwiftUI
import MapKit

struct RestaurantMap: View {
    struct Place: Identifiable {
        let id: UUID
        let location: CLLocationCoordinate2D

        init(id: UUID = UUID(), location: CLLocationCoordinate2D) {
            self.id = id
            self.location = location
        }
    }

    let place: Place
    @State private var region: MKCoordinateRegion

    init(location: CLLocationCoordinate2D) {
        place = Place(location: location)
        _region = State(initialValue: MKCoordinateRegion(center: location,
                                                         latitudinalMeters: 1000,
                                                         longitudinalMeters: 1000))
    }

    var body: some View {
        Group {
            Map(coordinateRegion: $region,
                annotationItems: [place]) { place in
                MapMarker(coordinate: place.location, tint: Color.red)
            }
        }
        .onChange(of: place.location) { location in
            region.center = location
        }
    }

}

struct RestaurantMap_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantMap(location: CLLocationCoordinate2D(latitude: 37.7244,
                                                       longitude: -122.4381))
            .environmentObject(ProgramState())
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
