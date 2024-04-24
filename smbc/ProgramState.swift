//
//  ProgramState.swift
//  smbc
//
//  Created by Marco S Hyman on 7/24/19.
//

import SwiftUI
import Observation

/// The server URL as a string and the name of the folder used to hold most of the schedule data
///
let serverName = "https://smbc.snafu.org/"
let serverDir = "schedule/"

/// A class to hold program state
///
@MainActor
@Observable
class ProgramState {
    /// The various models that make up the total state of the system
    ///
    var yearModel = YearModel()
    var restaurantModel = RestaurantModel()
    var rideModel = RideModel()
    var tripModel = TripModel()

    // The year of the loaded schedule as a string

    var scheduleYearString: String {
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear
        return String(format: "%4d", scheduleYear)
    }

    /// refresh schedule model data from the server
    ///
    func refresh(_ schedYear: Int) async throws {
        @AppStorage(ASKeys.refreshDate) var refreshDate = Date()

        do { try await yearModel.fetch() } catch {
            throw FetchError.yearModelError
        }
        do { try await restaurantModel.fetch() } catch {
            throw FetchError.restaurantModelError
        }
        do {
            try await rideModel.fetch(scheduleFor: schedYear)
        } catch {
            throw FetchError.rideModelError
        }
        do { try await tripModel.fetch() } catch {
            throw FetchError.tripModelError
        }

        // set the refresh date to 10 days in the future

        refreshDate = Calendar.current.date(byAdding: .day,
                                            value: 10,
                                            to: Date()) ?? Date()
    }
}
