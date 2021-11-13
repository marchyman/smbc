//
//  RestaurantDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
//  Copyright © 2019, 2021 Marco S Hyman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import SwiftUI

/// Restaurant detail view.
///
/// This view is used when a restaurant is sellect for the list of restaurants and when a Sunday morning
/// ride is selected from the rides list.
struct RestaurantDetailView : View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject var state: ProgramState
//    @State private var selectorIndex = 0
    @State private var showVisits = false


    let restaurant: Restaurant
    let eta: Bool

    var body: some View {
        GeometryReader {
            g in
            VStack {
                restaurantInfo
                    .frame(minHeight: 0, maxHeight: g.size.height * 0.35)
                MapInfoView(restaurant: restaurant)
                    .frame(minHeight: 0, maxHeight: g.size.height * 0.65)
            }
            .background(backgroundGradient(self.colorScheme))
            .navigationBarItems(trailing: self.showVisitButton)
        }
    }
    
    var showVisitButton: some View {
        Button("Show Visits") {
            self.showVisits = true
        }
        .sheet(isPresented: self.$showVisits) {
            RideVisitsView(isActive: self.$showVisits, restaurant: self.restaurant)
                .environmentObject(state)
        }
    }

    var restaurantInfo: some View {
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
                    Button( action: mapLink ) {
                        Text("Route: \(restaurant.route)")
                    }
                    Spacer()
                    Text("ETA: \(restaurant.eta)")
                }.padding([.top, .leading, .trailing])
            } else {
                Text(restaurant.route).padding(.top)
            }
        }.frame(minWidth: 0, maxWidth: .infinity,
                minHeight: 0, maxHeight: .infinity)
    }

    private
    func mapLink() {
        let mapPath = "https://maps.apple.com/?daddr="
            + restaurant.address.map { $0 == " " ? "+" : $0 }
            + ","
            + restaurant.city.map { $0 == " " ? "+" : $0 }
            + ",CA"
        guard let string = NSString(string: mapPath)
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
              let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }
}

#if DEBUG
struct RestaurantDetailView_Previews : PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant(id: "test",
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
            .environmentObject(state)
    }
}
#endif
