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
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TabView")
        .onChange(of: store.lastFetchError) {
            fetchErrorPresented = store.lastFetchError != nil
        }
        .onChange(of: store.nextRide) {
            if store.nextRide != nil {
                selectedTab = .rides
            }
        }
        .alert("Reload Error", isPresented: $fetchErrorPresented) {
            // system provides a button to dismiss
        } message: {
            ReloadErrorView(description: store.lastFetchError)
        }
        .onAppear {
            uiTestReloadError()
            uiTestNextRide()
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

extension ContentView {
    func uiTestReloadError() {
#if DEBUG
        if ProcessInfo.processInfo.environment["RELOADERRORTEST"] != nil {
            store.send(.forcedFetchRequested) {
                store.send(.fetchError("Test Fetch Failure"))
            }
        }
#endif
    }

    func uiTestNextRide() {
#if DEBUG
        if ProcessInfo.processInfo.environment["NEXTRIDETEST"] != nil {
            store.send(.gotNextRide(store.rideModel.rides.first))
        }
#endif
    }
}

#Preview {
    HomeView()
}
