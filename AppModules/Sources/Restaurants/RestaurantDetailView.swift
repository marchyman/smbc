//
//  RestaurantDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
//

import MapKit
import Schedule
import SwiftUI
import ViewModifiers

/// Restaurant detail view.
///
/// This view is used when a restaurant is sellect for the list of
/// restaurants and when a Sunday morning ride is selected from the rides list.
public struct RestaurantDetailView: View {
    @State private var showVisits = false
    @State private var orientation = UIDeviceOrientation.unknown

    let restaurant: Restaurant
    let eta: Bool

    public init(restaurant: Restaurant, eta: Bool) {
        self.restaurant = restaurant
        self.eta = eta
    }

    public var body: some View {
        GeometryReader { geometry in
            Group {
                switch orientation {
                case .landscapeLeft, .landscapeRight:
                    HStack {
                        RestaurantInfoView(restaurant: restaurant, eta: eta)
                            .frame(
                                minHeight: 0,
                                maxHeight: geometry.size.width * 0.35)
                        RestaurantMapView(restaurant: restaurant)
                    }
                default:
                    VStack {
                        RestaurantInfoView(restaurant: restaurant, eta: eta)
                            .frame(
                                minHeight: 0,
                                maxHeight: geometry.size.height * 0.35)
                        RestaurantMapView(restaurant: restaurant)
                    }
                }
            }
            .smbcBackground()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Show Visits") {
                        showVisits.toggle()
                    }
                }
            }
            .sheet(isPresented: $showVisits) {
                RestaurantVisitsView(restaurant: restaurant)
            }
        }
        .onAppear {
            orientation = UIDevice.current.orientation
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(
            restaurant: Restaurant(
                id: "beachstreet",
                name: "Beach Street",
                address: "435 W. Beach Street",
                route: "101/92/280/85/17/1",
                city: "Watsonville",
                phone: "831-722-2233",
                status: "open",
                eta: "8:17",
                lat: 37.113013,
                lon: -121.637845),
            eta: false
        )
    }
}
