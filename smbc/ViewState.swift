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
    case gallery
}

@MainActor
@Observable
final class ViewState {
    var selectedTab: TabItems = .home
    var nextRide: ScheduledRide?
    var forceRefresh = false
    var refreshPresented = false
    var refreshError: String = ""
    var refreshErrorPresented = false

    static let shared: ViewState = .init()

    private init() { }
}

extension ViewState {
    // refresh model data from server when necessary
    //
    // Refresh rules:
    // 1) Refresh when asked due to a long press on SmbcImage
    // 2) Refresh when the current date is greater than the refreshDate
    // 3) Refresh for the following year when there are no more rides for the year
    // 4) Refresh when the current schedule is not loaded.  Handle the case where
    //   the current date is the end of the year
    func refresh(_ state: ProgramState) async {
        @AppStorage(ASKeys.refreshDate) var refreshDate = Date()
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear

        var needRefresh = false
        let today = Date()
        var year = Calendar.current.component(.year, from: today)

        if forceRefresh {
            forceRefresh = false
            needRefresh = true
        } else if today > refreshDate {
            needRefresh = true
        } else if year == scheduleYear && state.rideModel.nextRide() == nil {
            year += 1
            needRefresh = true
        } else {
            let weekOfYear = Calendar.current.component(.weekOfYear, from: today)
            if weekOfYear <= 52 && year != scheduleYear {
                needRefresh = true
            }
        }
        if needRefresh {
            do {
                try await state.refresh(year)
            } catch let error {
                refreshError = error.localizedDescription
                refreshErrorPresented.toggle()
            }
        }
    }
}
