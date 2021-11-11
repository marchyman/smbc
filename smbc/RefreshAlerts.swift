//
//  RefreshAlerts.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
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
