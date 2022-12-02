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

/// The schedule for a year is stored in the app bundle to initialize needed state before updated
/// data is downloaded from the SMBC server.  This is the year of the stored schedule
///
fileprivate let bundleScheduleYear = 2023

/// A class to hold program state
///
@MainActor
class ProgramState: ObservableObject {
    /// user defaults
    ///
    @Published var year: Int {
        didSet {
            UserDefaults.standard.set(year, forKey: "year")
        }
    }
    @Published var refreshTime: Date {
        didSet {
            UserDefaults.standard.set(refreshTime, forKey: "refreshTime")
        }
    }
    @Published var mapTypeIndex: Int {
        didSet {
            UserDefaults.standard.set(mapTypeIndex, forKey: "mapTypeIndex")
        }
    }

    /// The various models that make up the total state of the system
    ///
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
    var yearString: String {
        String(format: "%4d", year)
    }
    var nextRide: ScheduledRide? {
        rideModel.nextRide(for: year)
    }

    /// True if it is time to refresh data from the server
    ///
    var needRefresh: Bool = false

    init() {
        year = UserDefaults.standard.object(forKey: "year")
            as? Int ?? bundleScheduleYear
        refreshTime = UserDefaults.standard.object(forKey: "refreshTime")
            as? Date ?? Date()
        mapTypeIndex = UserDefaults.standard.object(forKey: "mapTypeIndex")
            as? Int ?? 0

        // Maybe we need to refresh model data
        needRefresh = refreshTime < Date()

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

    /// refresh schedule model data from the server
    ///
    func refresh() async throws {
        if needRefresh {
            do { try await yearModel.fetch() } catch {
                throw FetchError.yearModelError
            }
            do { try await restaurantModel.fetch() } catch {
                throw FetchError.restaurantModelError
            }
            do { try await rideModel.fetch(year: year) } catch {
                throw FetchError.rideModelError
            }
            do { try await tripModel.fetch() } catch {
                throw FetchError.tripModelError
            }
            refreshTime = Date()
            needRefresh = false
        }
    }
}

/// Date fetching error types
///
enum FetchError: Error {
    case yearModelError
    case restaurantModelError
    case rideModelError
    case tripModelError
}

extension FetchError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .yearModelError:
            return "Year Model Fetch Failure"
        case .restaurantModelError:
            return "Restaurant Model Fetch Failure"
        case .rideModelError:
            return "Ride Model Fetch Error"
        case .tripModelError:
            return "Trip Model Fetch Error"
        }
    }
}
