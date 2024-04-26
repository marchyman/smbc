//
//  ViewState.swift
//  smbc
//
//  Created by Marco S Hyman on 4/25/24.
//  Copyright © 2024 Marco S Hyman. All rights reserved.
//

import SwiftUI

// Button text and Navigation Link values
enum Keys {
    static let rides = "Rides"
    static let restaurants = "Restaurants"
}

// State shared among views
@Observable
final class ViewState {
    var selectedTab: TabItems = .home
    var path: NavigationPath = .init()
    var noMoreRides: Bool = false
    var refreshPresented = false
    var forceRefresh = false
    var runRefreshTask = false
    var refreshError: String = ""
    var refreshErrorPresented = false
    var nextRide: ScheduledRide? = nil
}
