//
//  YearModel.swift
//  smbc
//
//  Created by Marco S Hyman on 11/8/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
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

fileprivate let yearModelName = "schedule-years.json"

/// A string containting a 4 digit year for which a schedule exists
///
struct ScheduleYear: Codable, Equatable {
    var year: String
}

/// A list of years for which a schedule exists.
///
@MainActor
class YearModel: ObservableObject {
    @Published var scheduleYears: [ScheduleYear]

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

    /// Find the index into scheduleYears for the entry that matches the given year
    /// - Parameter year: The year to find
    /// - Returns: The index matching the given year
    ///
    /// The year is assumed to exist in the array.  If not the program aborts.
    ///
    func findYearIndex(year: ScheduleYear) -> Int {
        guard let ix = scheduleYears.firstIndex(of: year) else {
            fatalError("Cannot find index for requested year")
        }
        return ix
    }

}
