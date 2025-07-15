//
//  LookaroundView.swift
//  smbc
//
//  Created by Marco S Hyman on 8/2/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

@preconcurrency import MapKit
import SwiftUI

struct LookAroundView: View {
    var marker: RestaurantMapView.MarkerModel
    @State private var lookAroundScene: MKLookAroundScene?

    var body: some View {
        ZStack {
            Text("*Look Around* not available for this location")
                .opacity(lookAroundScene == nil ? 1 : 0)
                .accessibilityIdentifier("lookaround")
            LookAroundPreview(initialScene: lookAroundScene)
                .opacity(lookAroundScene == nil ? 0 : 1)
        }
        .task {
            let request = MKLookAroundSceneRequest(coordinate: marker.location)
            lookAroundScene = try? await request.scene
        }
    }
}

#Preview("No Data") {
    LookAroundView(
        marker: RestaurantMapView.MarkerModel(
            id: "bogus",
            location: CLLocationCoordinate2D(
                latitude: 37.308351,
                longitude: -122.90166),
            title: "Bogus")
    )
    .frame(height: 128)
    .background(.thinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding(5)
}

#Preview("Data") {
    LookAroundView(
        marker: RestaurantMapView.MarkerModel(
            id: "countryinn3",
            location: CLLocationCoordinate2D(
                latitude: 37.325222,
                longitude: -122.013779),
            title: "Country Inn")
    )
    .frame(height: 128)
    .background(.thinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding(5)
}
