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
        @AppStorage(ASKeys.refreshTime) var refreshTime = Date()

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
        refreshTime = Date()
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
            return "Failed to fetch list of available schedules"
        case .restaurantModelError:
            return "Failed to fetch Restaurant information"
        case .rideModelError:
            return "Failed to fetch Ride information"
        case .tripModelError:
            return "Failed to fetch Trip information"
        }
    }
}
