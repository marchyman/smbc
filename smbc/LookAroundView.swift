//
//  LookaroundView.swift
//  smbc
//
//  Created by Marco S Hyman on 8/2/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import SwiftUI
import MapKit

struct LookAroundView: View {
    var marker: RestaurantMapView.MarkerModel
    @State private var lookAroundScene: MKLookAroundScene?
    
    var body: some View {
        ZStack {
            Text("*Look Around* not available for this location")
                .opacity(lookAroundScene == nil ? 1 : 0)
            LookAroundPreview(initialScene: lookAroundScene)
                .opacity(lookAroundScene == nil ? 0 : 1)
        }
        .task {
            lookAroundScene = await getLookAroundScene()
        }
    }

    func getLookAroundScene() async -> MKLookAroundScene? {
        let location = marker.location
        let request = MKLookAroundSceneRequest(coordinate: location)
        return try? await request.scene
    }
}

#Preview("No Data") {
    LookAroundView(marker: RestaurantMapView.MarkerModel(
        id: "beachstreet",
        location: CLLocationCoordinate2D(latitude: 36.906494, longitude: -121.764847),
        title: "Beach Street"))
        .frame (height: 128)
        .background (.thinMaterial)
        .clipShape (RoundedRectangle (cornerRadius: 10))
        .padding(5)
}

#Preview("Data") {
    LookAroundView(marker: RestaurantMapView.MarkerModel(
        id: "countryinn3",
        location: CLLocationCoordinate2D(latitude: 37.325222,
                                         longitude: -122.013779),
        title: "Country Inn"))
        .frame (height: 128)
        .background (.thinMaterial)
        .clipShape (RoundedRectangle (cornerRadius: 10))
        .padding(5)
}
