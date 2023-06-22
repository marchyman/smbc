//
//  RestaurantMapView.swift
//  smbc
//
//  Created by Marco S Hyman on 1/23/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import SwiftUI
import MapKit

struct RestaurantMapView: View {
    let restaurant: Restaurant

    var body: some View {
        let location = CLLocationCoordinate2D(latitude: restaurant.lat,
                                              longitude: restaurant.lon)
        Map(initialPosition:
                MapCameraPosition.region(
                    MKCoordinateRegion(center: location,
                                       latitudinalMeters: 1000,
                                       longitudinalMeters: 1000)
                    )
        ) {
            Marker(restaurant.name, coordinate: location)
                .tint(.red)
        }
    }
}

#Preview {
    let restaurant = Restaurant(id: "beachstreet",
                                name: "Beach Street",
                                address: "435 W. Beach Street",
                                route: "101/92/280/85/17/1",
                                city: "Watsonville",
                                phone: "831-722-2233",
                                status: "open",
                                eta: "8:17",
                                lat: 37.113013,
                                lon: -121.637845)

    return RestaurantMapView(restaurant: restaurant)
}
