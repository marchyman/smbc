//
//  RideModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/28/19.
//

import Observation
import SwiftUI

private let scheduleBase = "schedule"
private let scheduleExt = "json"

/// Format of a scheduled ride record retrieved from server
/// All rides have a start date.
/// Breakfast rides have restaurant and possibly a comment
/// Trips may have an end date. The will have a description and possibly a comment
/// An id is synthesized from the start date and either the restaurant
/// or the first word of the description
///
struct ScheduledRide: Codable, Identifiable, Hashable {
    let start: String
    let restaurant: String?
    let end: String?
    let description: String?
    let comment: String?

    var id: String {
        var id = start + "-"
        if let restaurant {
            id += restaurant
        } else if let description {
            id += description.components(separatedBy: " ").first ?? "desc"
        } else {
            id += "unknown"
        }
        return id
    }

    var month: Int {
        Int(String(start.split(separator: "/")[0])) ?? 0
    }
    var day: Int {
        Int(String(start.split(separator: "/")[1])) ?? 0
    }
}

@MainActor
@Observable
final class RideModel {
    var rides = [ScheduledRide]()

    /// The name of the cached schedule file
    ///
    let scheduleFileName = scheduleBase + "." + scheduleExt

    /// Initialize the list of scheduled rides from the cache
    ///
    init() {
        let cache = Cache(name: scheduleFileName, type: [ScheduledRide].self)
        rides = cache.cachedData()
    }

    /// fetch  data from the server for the desired year and update the model.
    ///
    func fetch(scheduleFor year: Int) async throws {
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear
        rides = try await Downloader.fetch(
            name: scheduleFileName,
            url: ridesUrl(for: year),
            type: [ScheduledRide].self)
        scheduleYear = year
    }

    /// The  next breakfast ride on a date >=  todays  date
    ///
    func nextRide() -> ScheduledRide? {
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear
        let monthDay: String
        guard
            let yesterday = Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: Date())
        else {
            return nil
        }
        let year = Calendar.current.component(.year, from: yesterday)
        guard year <= scheduleYear else { return nil }
        if year == scheduleYear {
            let month = Calendar.current.component(.month, from: yesterday)
            let day = Calendar.current.component(.day, from: yesterday)
            monthDay = "\(month)/\(day)"
        } else {
            monthDay = "0/0"  // give me the first ride of schedYear
        }
        return ride(following: monthDay)
    }

    /// return the ride from the rides array following the ride with the
    /// given start data Only Sunday rides to breakfast are returned.
    /// The function skips over trips.
    ///
    func ride(following start: String) -> ScheduledRide? {
        let date = start.split(separator: "/")
        let month = Int(String(date[0])) ?? 0
        let day = Int(String(date[1])) ?? 0
        guard
            let index = rides.firstIndex(where: {
                ($0.month > month || ($0.month == month && $0.day > day))
                    && $0.restaurant != nil
            })
        else { return nil }
        return index < rides.endIndex ? rides[index] : nil
    }

    /// return the ride following the given ride assuming one exists.
    /// This function skips over trips.

    func ride(following ride: ScheduledRide) -> ScheduledRide? {
        if let rideIndex = rides.firstIndex(of: ride) {
            var offset = 1
            while rideIndex + offset < rides.count {
                if rides[rideIndex + offset].restaurant != nil {
                    return rides[rideIndex + offset]
                }
                offset += 1
            }
        }
        return nil
    }

    /// return the ride preceding the given ride assuming one exists.
    /// This functipn skips over trips.

    func ride(preceding ride: ScheduledRide) -> ScheduledRide? {
        if let rideIndex = rides.firstIndex(of: ride) {
            var offset = 1
            while rideIndex - offset >= 0 {
                if rides[rideIndex - offset].restaurant != nil {
                    return rides[rideIndex - offset]
                }
                offset += 1
            }
        }
        return nil
    }

    /// Build the full name of the Scheduled Rides file on the server
    ///
    private func ridesUrl(for year: Int) -> URL {
        let fullName =
            serverName + serverDir + scheduleBase + "-" + String(year) + "." + scheduleExt
        return URL(string: fullName)!
    }

}
