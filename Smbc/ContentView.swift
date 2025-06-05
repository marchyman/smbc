//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Gallery
import Home
import Restaurants
import Rides
import Schedule
import SwiftUI
import UDF

enum TabItems {
    case home
    case restaurants
    case rides
    case gallery
}

public struct ContentView: View {
    @Environment(Store<ScheduleState, ScheduleAction>.self) var store
    @State private var selectedTab: TabItems = .home
    @State private var fetchErrorPresented = false

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(TabItems.home)

            RestaurantListView()
                .tabItem { Label("Restaurants", systemImage: "fork.knife") }
                .tag(TabItems.restaurants)

            RideListView()
                .tabItem { Label("Rides", image: .motoiconSFSymbol) }
                .tag(TabItems.rides)

            GalleryView()
                .tabItem { Label("Gallery", systemImage: "photo") }
                .tag(TabItems.gallery)
        }
        .onChange(of: store.state.lastFetchError) {
            fetchErrorPresented = store.state.lastFetchError != nil
        }
        .onChange(of: store.state.nextRide) {
            if store.state.nextRide != nil {
                selectedTab = .rides
            }
        }
        .alert("Reload Error", isPresented: $fetchErrorPresented) {
            // system provides a button to dismiss
        } message: {
            ReloadErrorView(description: store.state.lastFetchError)
        }
    }
}

struct ReloadErrorView: View {
    let description: String?

    var body: some View {
        Text(
            """
            \(description ?? "Unknown error")

            There may be internet and/or server issues. As a result the \
            ride schedule data on this device may be out of date.

            Please try to refresh the data again once the issue has been \
            resolved. You can also obtain the current schedule from the \
            [SMBC home page](https://smbc.snafu.org).
            """)
    }
}

#Preview {
    HomeView()
}
