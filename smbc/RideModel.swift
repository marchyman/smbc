//
//  RideModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/28/19.
//

import Foundation
import Combine

fileprivate let scheduleBase = "schedule"
fileprivate let scheduleExt = "json"

/// Format of a scheduled ride record retrieved from server
/// All rides have an ID and a start date.
/// Breakfast rides have restaurant and possibly a comment
/// Trips have an end date , a description, and possibly a comment
///
struct ScheduledRide: Codable, Identifiable, Hashable {
    let id = UUID()
    let start: String
    let restaurant: String?
    let end: String?
    let description: String?
    let comment: String?
    
    var month: Int {
        Int(String(start.split(separator: "/")[0])) ?? 0
    }
    var day: Int {
        Int(String(start.split(separator: "/")[1])) ?? 0
    }

    // We never decode the ID.
    private enum CodingKeys: String, CodingKey {
        case start
        case restaurant
        case end
        case description
        case comment
    }
}

@MainActor
class RideModel: ObservableObject {
    @Published var rides = [ScheduledRide]()

    /// The name of the cached schedule file
    ///
    var scheduleFileName = scheduleBase + "." + scheduleExt

    /// Initialize the list of scheduled rides from the cache
    ///
    init() {
        let cache = Cache(name: scheduleFileName, type: [ScheduledRide].self)
        rides = cache.cachedData()
    }

    /// fetch current data from the server  and update the model.
    ///
    func fetch(year: Int) async throws {
        rides = try await Downloader.fetch(
            name: scheduleFileName,
            url: ridesUrl(for: year),
            type: [ScheduledRide].self
        )
    }

    /// The  next breakfast ride on a date >=  todays  date
    ///
    func nextRide(for schedYear: Int) -> ScheduledRide? {
        let md: String
        guard let yesterday = Calendar
            .current.date(byAdding: .day,
                          value: -1,
                          to: Date())
        else {
            return nil
        }
        let year = Calendar.current.component(.year, from: yesterday)
        guard year <= schedYear else { return nil }
        if year == schedYear {
            let month = Calendar.current.component(.month, from: yesterday)
            let day = Calendar.current.component(.day, from: yesterday)
            md = "\(month)/\(day)"
        } else {
            md = "0/0" // give me the first ride of schedYear
        }
        return ride(following: md)
    }

    /// Build the full name of the Scheduled Rides file on the server
    ///
    private
    func ridesUrl(for year: Int) -> URL {
        let fullName = serverName +
            serverDir +
            scheduleBase +
            "-" +
            String(year) +
            "." +
            scheduleExt
        return URL(string: fullName)!
    }

    /// return the ride from the rides array following the ride with the given start data
    /// Only Sunday rides to breakfast are returned.  The function skips over trips.
    ///
    func ride(following start: String) -> ScheduledRide? {
        let date = start.split(separator: "/")
        let month = Int(String(date[0])) ?? 0
        let day = Int(String(date[1])) ?? 0
        guard let index = rides.firstIndex(where: {
            ($0.month > month ||
            ($0.month == month && $0.day > day)) &&
            $0.restaurant != nil
        }) else { return nil }
        return index < rides.endIndex ? rides[index] : nil
    }
}
