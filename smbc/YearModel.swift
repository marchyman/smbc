//
//  YearModel.swift
//  smbc
//
//  Created by Marco S Hyman on 11/8/21.
//

import Foundation
import Observation

private let yearModelName = "schedule-years.json"

/// A string containting a 4 digit year for which a schedule exists
///
struct ScheduleYear: Codable, Equatable {
    var year: String
}

/// A list of years for which a schedule exists.
///
@Observable
final class YearModel {
    var scheduleYears: [ScheduleYear]

    // Initialize YearsModel from the cache.
    init() {
        let cache = Cache(name: yearModelName, type: [ScheduleYear].self)
        scheduleYears = cache.cachedData()
    }

    /// fetch current data from the server and update the model.
    ///
    func fetch() async throws {
        let url = URL(string: serverName + serverDir + yearModelName)!
        scheduleYears = try await Downloader.fetch(
            name: yearModelName,
            url: url,
            type: [ScheduleYear].self
        )
    }

    /// Check if a schedule exists for a given year
    /// - Parameter year:   the year to check
    /// - Returns:          true if a schedule exists for year
    ///
    func scheduleExists(for year: Int) -> Bool {
        let yearString = String(format: "%4d", year)
        let scheduleYear = ScheduleYear(year: yearString)
        return scheduleYears.contains(scheduleYear)
    }

    /// Find the index into scheduleYears for the entry that matches the given year
    /// - Parameter year: The year to find
    /// - Returns: The index matching the given year
    ///
    /// The year is assumed to exist in the array.  If not the program aborts.
    ///
    func findYearIndex(for year: Int) -> Int {
        let scheduleYear = ScheduleYear(year: String(year))
        guard let ix = scheduleYears.firstIndex(of: scheduleYear) else {
            fatalError("Cannot find index for requested year")
        }
        return ix
    }

}
