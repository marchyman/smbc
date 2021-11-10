//
//  ProgramState.swift
//  smbc
//
//  Created by Marco S Hyman on 7/24/19.
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

import Foundation
import Combine

/// The server URL as a string and the name of the folder used to hold most of the schedule data
///
let serverName = "https://smbc.snafu.org/"
let serverDir = "schedule/"



/// A class to hold program state
///
@MainActor
class ProgramState: ObservableObject {
    /// The various models that make up the total state of the system
    ///
    var savedState = SavedState.load() {
        didSet {
            SavedState.store(savedState)
        }
    }
    var yearModel = YearModel()
    var restaurantModel = RestaurantModel()
    var rideModel = RideModel()
    var tripModel = TripModel()

    // Handle propagating changes from the sub-models
    var yearCancellable: AnyCancellable? = nil
    var restaurantCancellable: AnyCancellable? = nil
    var rideCancellable: AnyCancellable? = nil
    var tripCancellable: AnyCancellable? = nil

    // convenience variables
    //
    var year: Int { savedState.year }
    var yearString: String {
        String(format: "%4d", year)
    }
    var nextRide: ScheduledRide? {
        rideModel.nextRide(for: year)
    }

    /// index into the yearModel array of years that matches the schedule year
    ///
    var yearIndex: Int
    /// True if it is time to refresh data from the server
    ///
    var needRefresh: Bool

    init() {
        yearIndex = 0   // shut compiler up
        needRefresh = savedState.refreshTime < Date()
        yearIndex = yearModel.findYearIndex(for: yearString)

        // propagate object will change notifications from the sub-models
        yearCancellable =
            yearModel.objectWillChange.sink { (_) in
                self.objectWillChange.send()
            }
        restaurantCancellable =
            restaurantModel.objectWillChange.sink { (_) in
                self.objectWillChange.send()
            }
        rideCancellable =
            rideModel.objectWillChange.sink { (_) in
                self.objectWillChange.send()
            }
        tripCancellable =
            tripModel.objectWillChange.sink { (_) in
                self.objectWillChange.send()
            }
    }
}
