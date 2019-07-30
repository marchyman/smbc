//
//  RideModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/28/19.
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
import Combine

/// Format of a scheduled ride record retrieved from server
/// All rides have an ID and a start date.
/// Breakfast rides have restaurant and possibly a comment
/// Trips have an end date , a description, and possibly a comment
struct ScheduledRide: Decodable, Identifiable {
    let id = UUID()
    let start: String
    let restaurant: String?
    let end: String?
    let description: String?
    let comment: String?
}

class RideModel: ObservableObject {
    let scheduleBase = "schedule"
    let scheduleExt = "json"

    @Published var rides = [ScheduledRide]()
    @Published var fileUnavailable = false

    var programState: ProgramState
    var rideYear: String

    init(programState: ProgramState, refresh: Bool) {
        self.programState = programState
        rideYear = programState.scheduleYears[programState.cachedIndex].year
        let name = scheduleBase + "." + scheduleExt
        let fullName = serverName +
                        "schedule/" +
                        scheduleBase +
                        "-" +
                        rideYear +
                        "." +
                        scheduleExt
        
        let cache = Cache(name: name, type: [ScheduledRide].self)
        if refresh {
            let url = URL(string: fullName)!
            let cacheUrl = try? cache.fileUrl()
            let downloader = Downloader(url: url,
                                        type: [ScheduledRide].self,
                                        cache: cacheUrl)
            downloader
                .publisher
                .catch {
                    _ in
                    return Just(cache.cachedData())
                }
                .assign(to: \.rides, on: self)
        } else {
            rides = cache.cachedData()
        }
    }

    /// Fetch ride data when a different year is sellected
    ///
    /// Unlike the initial data download this function does not use cached data upon failure.
    ///
    func fetchRideData() {
        if programState.cachedIndex != programState.selectedIndex {
            let name = scheduleBase + "." + scheduleExt
            let cache = Cache(name: name, type: [ScheduledRide].self)
            let cacheUrl = try? cache.fileUrl()
            let year = programState.scheduleYears[programState.selectedIndex].year
            let fullName = serverName +
                "schedule/" +
                scheduleBase +
                "-" +
                year +
                "." +
                scheduleExt
            let fileUrl = URL(string: fullName)!
            let downloader = Downloader(url: fileUrl,
                                        type: [ScheduledRide].self,
                                        cache: cacheUrl)
            downloader
                .publisher
                .sink(receiveCompletion: {
                        error in
                        print("\(#function) error: \(error)")
                        if case .failure = error {
                            self.fileUnavailable = true
                        }
                      },
                      receiveValue: {
                        output in
                        self.rides = output
                        self.rideYear = year
                        self.programState.cachedIndex = self.programState.selectedIndex
                        ProgramState.store(self.programState)
                      })

        }
    }

    /// return the ride from the rides array following the ride with the given start data
    /// Only Sunday rides to breakfast are returned.  The function skips over trips.
    ///
    func ride(following start: String) -> ScheduledRide? {
        guard var index = rides.firstIndex(where: { $0.start == start && $0.restaurant != nil}) else {
            fatalError("Unknown start")
        }
        repeat {
            index = rides.index(after: index)
        } while index < rides.endIndex && rides[index].restaurant == nil
        return index < rides.endIndex ? rides[index] : nil
    }


}
