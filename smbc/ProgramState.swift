//
//  ProgramState.swift
//  smbc
//
//  Created by Marco S Hyman on 7/24/19.
//

import Observation
import SwiftUI

/// The server URL as a string and the name of the folder used to hold
/// most of the schedule data
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
    var galleryModel = GalleryModel()

    // The year of the loaded schedule as a string

    var scheduleYearString: String {
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear
        return String(format: "%4d", scheduleYear)
    }

    /// refresh schedule model data from the server
    ///
    func refresh(_ schedYear: Int) async throws {
        @AppStorage(ASKeys.refreshDate) var refreshDate = Date()

        Task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    do { try await self.yearModel.fetch() } catch {
                        throw FetchError.yearModelError
                    }
                }
                group.addTask {
                    do { try await self.restaurantModel.fetch() } catch {
                        throw FetchError.restaurantModelError
                    }
                }
                group.addTask {
                    do {
                        try await self.rideModel.fetch(scheduleFor: schedYear)
                    } catch {
                        throw FetchError.rideModelError
                    }
                }
                group.addTask {
                    do { try await self.tripModel.fetch() } catch {
                        throw FetchError.tripModelError
                    }
                }
                group.addTask {
                    do { try await self.galleryModel.fetch() } catch {
                        throw FetchError.galleryError
                    }
                }
            }
        }

        // set the refresh date to 10 days in the future

        refreshDate =
            Calendar.current.date(
                byAdding: .day,
                value: 10,
                to: Date()) ?? Date()
    }
}
