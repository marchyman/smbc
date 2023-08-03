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
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay {
                Text("No data for this location")
                    .padding(5)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .opacity(lookAroundScene == nil ? 1 : 0)
            }
            .onAppear {
                getLookAroundScene()
            }
    }
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: marker.location)
            lookAroundScene = try? await request.scene
            if lookAroundScene == nil {
                print("Couldn't get scene for \(marker.title)")
            }
        }
    }
}

#Preview {
    LookAroundView(marker: RestaurantMapView.MarkerModel(
        id: "beachstreet",
        location: CLLocationCoordinate2D(latitude: 36.906494, longitude: -121.764847),
        title: "Beach Street"))
}
