//
//  ProgramState.swift
//  smbc
//
//  Created by Marco S Hyman on 7/24/19.
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
private let bundleScheduleYear = 2023

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
    var yearCancellable: AnyCancellable?
    var restaurantCancellable: AnyCancellable?
    var rideCancellable: AnyCancellable?
    var tripCancellable: AnyCancellable?

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
    func refresh(_ year: Int) async throws {
        if needRefresh {
            do { try await yearModel.fetch() } catch {
                throw FetchError.yearModelError
            }
            do { try await restaurantModel.fetch() } catch {
                throw FetchError.restaurantModelError
            }
            do {
                try await rideModel.fetch(year: year)
                self.year = year
            } catch {
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
