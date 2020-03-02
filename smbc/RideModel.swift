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
    
    var month: Int {
        Int(String(start.split(separator: "/")[0])) ?? 0
    }
    var day: Int {
        Int(String(start.split(separator: "/")[1])) ?? 0
    }
}

class RideModel: ObservableObject {
    let scheduleBase = "schedule"
    let scheduleExt = "json"

    @Published var rides = [ScheduledRide]()
    @Published var fileUnavailable = false
    @Published var mapTypeIndex = 0
    
    var programState: ProgramState
    var rideYear: String
    
    private var cancellable: AnyCancellable?

    /// The  next breakfast ride on a date >=  todays  date
    var nextRide: ScheduledRide? {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return nil
        }
        let year = Calendar.current.component(.year, from: yesterday)
        guard year == Int(rideYear) else { return nil }
        let month = Calendar.current.component(.month, from: yesterday)
        let day = Calendar.current.component(.day, from: yesterday)
        let md = "\(month)/\(day)"
        return ride(following: md)
    }

    init(programState: ProgramState, refresh: Bool) {
        self.programState = programState
        rideYear = programState.scheduleYears[programState.cachedIndex].year
        let name = scheduleBase + "." + scheduleExt
        let cache = Cache(name: name, type: [ScheduledRide].self)
        if refresh {
            let url = ridesUrl(for: rideYear)
            let cacheUrl = try? cache.fileUrl()
            let downloader = Downloader(url: url,
                                        type: [ScheduledRide].self,
                                        cache: cacheUrl)
            cancellable = downloader
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
            let fileUrl = ridesUrl(for: year)
            let downloader = Downloader(url: fileUrl,
                                        type: [ScheduledRide].self,
                                        cache: cacheUrl)
            cancellable = downloader
                .publisher
                .sink(receiveCompletion: {
                        [weak self] error in
                        guard let self = self else {return }
                        if case .failure = error {
                            self.fileUnavailable = true
                        }
                      },
                      receiveValue: {
                        [weak self] output in
                        guard let self = self else { return }
                        self.rides = output
                        self.rideYear = year
                        self.programState.cachedIndex = self.programState.selectedIndex
                        ProgramState.store(self.programState)
                      })

        }
    }

    /// Build the full name of the Scheduled Rides file on the server
    ///
    private
    func ridesUrl(for year: String) -> URL {
        let fullName = serverName +
            "schedule/" +
            scheduleBase +
            "-" +
            year +
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
