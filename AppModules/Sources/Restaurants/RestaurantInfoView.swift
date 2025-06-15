//
//  RestaurantInfoView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import Schedule
import SwiftUI

struct RestaurantInfoView: View {
    let restaurant: Restaurant
    let eta: Bool

    var body: some View {
        VStack {
            Text(restaurant.name)
                .font(.title)
                .padding(.bottom)
            if restaurant.status != "open" {
                Text(restaurant.status)
                    .italic()
                    .font(.footnote)
                    .offset(x: 0, y: -20)
            }
            Text(restaurant.address)
            Text(restaurant.city)
            Text(restaurant.phone)
            Spacer()
            if eta {
                HStack {
                    if let url = mapLink() {
                        Link(destination: url) {
                            Text("Route: \(restaurant.route)")
                        }
                    }
                    Spacer()
                    Text("ETA: \(restaurant.eta)")

                }.padding([.top, .leading, .trailing])
                if restaurant.eta.hasSuffix("‡") {
                    Text("‡ ETA indicates restaurant open time.")
                        .font(.footnote)
                }
            } else {
                Text(restaurant.route).padding(.top)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func mapLink() -> URL? {
        let mapPath =
            "https://maps.apple.com/?daddr="
            + restaurant.address.map { $0 == " " ? "+" : $0 }
            + ","
            + restaurant.city.map { $0 == " " ? "+" : $0 }
            + ",CA"
        guard
            let string = NSString(string: mapPath)
                .addingPercentEncoding(
                    withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
            let url = URL(string: string)
        else { return nil }
        return url
    }
}

// does not build in Xcode 16, yet this view is part of RestaurantDetailView
// which previews without error.

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: Restaurant(
            id: "test",
            name: "Test Restaurant",
            address: "123 Main Street",
            route: "(101/202/303)",
            city: "Some City",
            phone: "(123) 456-7890",
            status: "CLOSED",
            eta: "8:05",
            lat: 37.7244,
            lon: -122.4381),
                             eta: false)
    }
}
