//
//  RestaurantDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
//

import SwiftUI

/// Restaurant detail view.
///
/// This view is used when a restaurant is sellect for the list of restaurants and when a Sunday morning
/// ride is selected from the rides list.
struct RestaurantDetailView : View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject var state: ProgramState
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
            .background(backgroundGradient(colorScheme))
            .navigationBarItems(trailing: showVisitButton)
        }
    }
    
    var showVisitButton: some View {
        Button("Show Visits") {
            showVisits = true
        }
        .sheet(isPresented: $showVisits) {
            RideVisitsView(restaurant: restaurant)
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
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
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

#if DEBUG
struct RestaurantDetailView_Previews : PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        NavigationStack {
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
}
#endif
