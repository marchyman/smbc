//
//  RefreshAlerts.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//

import SwiftUI

// swiftlint:disable line_length

struct RefreshAlerts {
    enum RefreshType: String {
        case refreshing
        case all
        case year
        case restaurant
        case ride
        case trip

        var view: Alert {
            switch self {
            case .refreshing:
                return Alert(
                    title: Text("Data refresh"),
                    message: Text("""
                                  Up to date Trip, Restaurant, and Schedule data is being retrieved from smbc.snafu.org

                                  It may take a few seconds for the updated data to be received and processed.
                                  """))
            default:
                return Alert(
                    title: Text("Refresh Error"),
                    message: Text("""
                                  An attempt to refresh \(self.rawValue) data failed. There may be internet and/or server issues. As a result the ride schedule data on this device may be out of date.

                                  Please try to refresh the data again once the issue has been resolved.  You can always find the current schedule on the SMBC home page.
                                  """))
            }
        }
    }

    var type: RefreshType
}

// swiftlint:enable line_length
