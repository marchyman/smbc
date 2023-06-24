//
//  RefreshAlerts.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//

import SwiftUI

enum RefreshType: String {
    case refreshing
    case all
    case year
    case restaurant
    case ride
    case trip

    var refreshError: String {
        // swiftlint:disable line_length
        """
        An attempt to refresh \(self.rawValue) data failed. There may be internet and/or server issues. As a result the ride schedule data on this device may be out of date.

        Please try to refresh the data again once the issue has been resolved.  You can always find the current schedule on the SMBC home page.
        """
        // swiftlint:enable line_length
    }
}

