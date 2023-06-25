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
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedItem: MKMapItem?

    // automatic positioning zooms in more than I like. Override the position
    // to be centered on the restaurant within a 1 km border

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        _position = State(initialValue: makePosition())
    }

    var body: some View {
        let location = CLLocationCoordinate2D(latitude: restaurant.lat,
                                              longitude: restaurant.lon)
        Map(position: $position, selection: $selectedItem) {
            Marker(restaurant.name, coordinate: location)
                .tag(restaurant.name)
                .tint(.red)
        }
        .onChange(of: restaurant) {
            position = makePosition()
        }
        .onChange(of: selectedItem) {
            // never printed.  Wait for the next beta?
            print("item selection changed")
        }
        .overlay(alignment: .bottom) {
            if let selectedItem {
                // replace this with a lookaround preview when
                // selection is working
                Text(selectedItem.description)
                    .frame (height: 128)
                    .clipShape (RoundedRectangle (cornerRadius: 10))
                    .padding ([.top, .horizontal])
                    .background (.thinMaterial)
            }
        }
    }

    private func makePosition() -> MapCameraPosition {
        return MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: restaurant.lat,
                                               longitude: restaurant.lon),
                latitudinalMeters: 1000,
                longitudinalMeters: 1000))
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
