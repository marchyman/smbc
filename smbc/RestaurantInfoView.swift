//
//  RestaurantInfoView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

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
            } else {
                Text(restaurant.route).padding(.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private
    func mapLink() -> URL? {
        let mapPath = "https://maps.apple.com/?daddr="
            + restaurant.address.map { $0 == " " ? "+" : $0 }
            + ","
            + restaurant.city.map { $0 == " " ? "+" : $0 }
            + ",CA"
        guard let string = NSString(string: mapPath)
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
              let url = URL(string: string) else { return nil }
        return url
    }

}

#Preview {
    RestaurantInfoView(restaurant: Restaurant(id: "beachstreet",
                                              name: "Beach Street",
                                              address: "435 W. Beach Street",
                                              route: "101/92/280/85/17/1",
                                              city: "Watsonville",
                                              phone: "831-722-2233",
                                              status: "open",
                                              eta: "8:17",
                                              lat: 37.113013,
                                              lon: -121.637845),
                       eta: false)
}
