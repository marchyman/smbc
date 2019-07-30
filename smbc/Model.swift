//
//  Model.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
//
//  Created by Marco S Hyman on 7/27/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
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

/// The model consists of 4 separate data types
/// * ProgramState -- locally stored holding state between runs
/// * RestaurantModel -- restaurant data fetched from the server and cached locally
/// * RideModel -- scheduled rides fetched from the server and cached locally
/// * TripModel -- details about trips
///
class Model {
    var programState: ProgramState
    var restaurantModel: RestaurantModel
    var rideModel: RideModel
    var tripModel: TripModel

    /// Initialize the data model
    /// - Parameter savedState: program state from the last time the program ran.  A default
    ///     state is passed in the first time the program is run
    init(savedState: ProgramState) {
        programState = savedState
        let needRefresh = programState.refreshTime < Date()
        restaurantModel = RestaurantModel(refresh: needRefresh)
        rideModel = RideModel(programState: programState,
                              refresh: needRefresh)
        tripModel = TripModel(refresh: needRefresh)
        if needRefresh {
            programState.refreshTime = Date() + TimeInterval(7 * 24 * 60 * 60)
            programState.updateScheduleYears()
        }
    }
}
