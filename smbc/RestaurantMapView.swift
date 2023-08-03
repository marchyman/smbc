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
    @State private var selectedId: String?
    @State private var popoverPresented = false
    @AppStorage(ASKeys.mapStyle) var mapStyle = 0

    let mapStyles = [MapStyle.standard, MapStyle.hybrid, MapStyle.imagery]

    // automatic positioning zooms in more than I like. Override the position
    // to be centered on the restaurant within a 1 km border

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        _position = State(initialValue: makePosition())
    }

    var body: some View {
        let markers = makeMarkers(for: restaurant)
        Map(position: $position, selection: $selectedId) {
            ForEach(markers) { marker in
                Marker(marker.title, coordinate: marker.location)
                    .tint(.red)
            }
        }
        .mapStyle(mapStyles[mapStyle])
        .onChange(of: restaurant) {
            position = makePosition()
        }
//        .onChange(of: selectedId) {
//            // never printed.  Wait for the next beta?
//            print("item selection changed")
//        }
        .overlay(alignment: .bottom) {
            if let marker = markers.first(where: { $0.id == selectedId }) {
                LookAroundView(marker: marker)
                    .frame (height: 128)
                    .clipShape (RoundedRectangle (cornerRadius: 10))
                    .padding()
                    .background (.thinMaterial)
            } else {
                styleButton
            }
        }
    }

    var styleButton: some View {
        HStack {
            Spacer()
            Button("Change Map Style") {
                popoverPresented.toggle()
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.horizontal)
            .padding(.bottom, 5)
            .popover(isPresented: $popoverPresented,
                     attachmentAnchor: .point(.center),
                     arrowEdge: .top) {
                Picker("Map Type", selection: $mapStyle) {
                    Text("Standard").tag(0)
                    Text("Hybrid").tag(1)
                    Text("Imagery").tag(2)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .padding()
                .presentationCompactAdaptation(.none)
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

    // Apparently needed for marker selection
    struct MarkerModel: Identifiable {
        var id: String
        var location: CLLocationCoordinate2D
        var title: String
    }

    private func makeMarkers(for restaurant: Restaurant) -> [MarkerModel] {
        let marker = MarkerModel(id: restaurant.id,
                                 location: CLLocationCoordinate2D(latitude: restaurant.lat,
                                                                  longitude: restaurant.lon),
                                 title: restaurant.name)
        return [marker]
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
                                lat: 36.906514,
                                lon: -121.764811)

    return RestaurantMapView(restaurant: restaurant)
}
