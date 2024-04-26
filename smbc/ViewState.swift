//
//  ViewState.swift
//  smbc
//
//  Created by Marco S Hyman on 4/25/24.
//  Copyright © 2024 Marco S Hyman. All rights reserved.
//

import SwiftUI

// State shared between view
enum TabItems {
    case home
    case restaurants
    case rides
}

@MainActor
@Observable
final class ViewState {
    var selectedTab: TabItems = .home
    var nextRide: ScheduledRide? = nil

    static let shared: ViewState = .init()

    private init() { }
}
