//
//  Data.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
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
import SwiftUI

/// Data for the SMBC App.
/// A list of restaurants and the current schedule is downloaded from smbc.snafu.org.  Once the
/// download is complete a copy of the retrieved data is placed in ~/Library/Caches/org.snafu.smbc.
/// If there is no network connectivity the application will use the cached data.   If there is no
/// network connectivity and data has never been cached data will be retrieved from the application
/// bundle.


/// Location and format of Restaurant and Ride data

fileprivate let serverName = "https://smbc.snafu.org/"
fileprivate let restaurantName = "restaurants.json"
fileprivate let scheduleBase = "schedule"
fileprivate let scheduleExt = "json"
fileprivate let scheduleName = scheduleBase + "." + scheduleExt
fileprivate let tripName = "trips.json"


/// Format of a restaurant record retrieved from server
struct Restaurant: Decodable, Identifiable {
    let id: String
    let name: String
    let address: String
    let route: String
    let city: String
    let phone: String
    let status: String
    let eta: String
    let lat: Double
    let lon: Double
}

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

/// SMBCData holds all data needed for the app.  It is stored in the environment.

class SMBCData: BindableObject {
    var programState: ProgramState

    let willChange = PassthroughSubject<Void, Never>()
    var restaurants = [Restaurant]()
    var rides = [ScheduledRide]()
    var trips = [String:String]()
    
    init() {
        programState = ProgramState.load()

        if programState.refreshTime < Date() {
            downloadRideYears()
            downloadRestaurants()
            downloadRides()
            downloadTrips()
            // 7 days * 24 hours/day * 60 minues.hour * 60 seconds/minute
            // is one week in seconds
            programState.refreshTime += TimeInterval(7 * 24 * 60 * 60)
            ProgramState.store(programState)
        } else {
            restaurantsFromCache()
            ridesFromCache()
            tripsFromCache()
        }
   }

    // MARK: - Fetch data for currently selected year

    func yearUpdated() {
        if programState.cachedIndex != programState.selectedIndex {
            downloadRides()
        }
    }

    // MARK: - Data look up functions
    
    /// return the restaurant from the restaurants array matching the given id.
    func idToRestaurant(id: String?) -> Restaurant {
        guard let id = id,
              let restaurant = restaurants.first(where: { $0.id == id }) else {
                fatalError("Missing Restaurant ID")
        }
        return restaurant
    }

    /// return the ride from the rides array following the ride with the given start data
    /// Only Sunday rides to breakfast are returned.  The function skips over trips.
    func ride(following start: String) -> ScheduledRide? {
        guard var index = rides.firstIndex(where: { $0.start == start && $0.restaurant != nil}) else {
            fatalError("Unknown start")
        }
        repeat {
            index = rides.index(after: index)
        } while index < rides.endIndex && rides[index].restaurant == nil
        return index < rides.endIndex ? rides[index] : nil
    }

    // MARK: - common functions for fetching restaurants and rides

    /// Copy data returned from a network request to a cache
    ///
    /// - Parameter source: URL of data to be cached
    /// - Parameter name: Name of file inside of cache folder.  If nil the file is not cached
    ///
    /// A  folder inside the users cachedDirectory will be created if necessary
    private
    func cacheData(source: URL, name: String?) throws {
        guard let name = name else { return }
        let fileManager = FileManager.default
        let cachesDir = try fileManager.url(for: .cachesDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
        let cacheFolderName = "\(Bundle.main.bundleIdentifier!)/"
        let cacheFolder = cachesDir.appendingPathComponent(cacheFolderName)
        try fileManager.createDirectory(at: cacheFolder,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        let cachedFile = cacheFolder.appendingPathComponent(name)
        if fileManager.fileExists(atPath: cachedFile.path) {
            try? fileManager.removeItem(at: cachedFile)
        }
        try fileManager.copyItem(at: source, to: cachedFile)

    }
    
    /// Read data from the local cache
    /// - Parameter name: Name of file in local cache.  The function is a no-op when name is nil
    /// - Parameter reader: closure called to process  data
    private
    func dataFromCache(name: String?, reader: @escaping (URL) throws -> ()) {
        guard let name = name else { return }
        let fileManager = FileManager.default
        do {
            let cachesDir = try fileManager.url(for: .cachesDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
            let cacheFolderName = "\(Bundle.main.bundleIdentifier!)/"
            let cacheFolder = cachesDir.appendingPathComponent(cacheFolderName)
            let cachedFile = cacheFolder.appendingPathComponent(name)
            try reader(cachedFile)
        } catch {
            dataFromBundle(name: name, reader: reader)
        }
        
    }

    private
    func dataFromBundle(name: String, reader: (URL) throws -> ()) {
        // break the name into base name and extension
        guard let dotIndex = name.lastIndex(of: ".") else {
            fatalError("malformed resource name: \(name)")
        }
        let resource = String(name.prefix(upTo:dotIndex))
        let extRange = name.index(after: dotIndex)..<name.endIndex
        let ext = String(name[extRange])

        // get data from bundle

        let url = Bundle.main.url(forResource: resource,
                                  withExtension: ext)
        do {
            try reader(url!)
        } catch {
            fatalError("Cannot find resource in bundle")
        }
    }

    // MARK: - download data using a URLSession
    
    /// Download and process data using a URLSession
    /// - Parameter name: name of the file to download  used for caching the results.  The file is
    ///                     not cached if this name is nil.
    /// - Parameter url: URL of the file to download
    /// - Parameter reader: function to call to process the downloaded data
    ///
    ///
    private
    func download(name: String?,
                  url: URL,
                  reader: @escaping (URL) throws -> Void) {
        URLSession.shared.downloadTask(with: url) {
            localURL, urlResponse, error in
            if let localURL = localURL,
                let response = urlResponse as? HTTPURLResponse,
                (200...299).contains(response.statusCode) {
                do {
                    try self.cacheData(source: localURL, name: name)
                    try reader(localURL)
                } catch {
                    // don't want to do this if trying to switch years
                    self.dataFromCache(name: name, reader: reader)
                }
            } else {
                // don't want to do this if trying to switch years
                self.dataFromCache(name: name, reader: reader)
            }
        }.resume()
    }

    // MARK: - Download array of years for which we have a ride schedule

    /// Attempt to download the current list of restaurants.
    ///
    /// Any failure will result in an attempt to read the restaurants from data cached during
    /// the last sucessful download.
    private
    func downloadRideYears() {
        let rideYearsName = "schedule/schedule-years.json"
        let rideYearsUrl = URL(string: serverName + rideYearsName)
        download(name: nil, url: rideYearsUrl!) {
            url in
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let years = try decoder.decode([ScheduleYear].self, from: data)
            DispatchQueue.main.async {
                self.programState.scheduleYears = years
            }
        }
    }

    // MARK: - Fetch restaurants
    
    /// decode and update the list of restaurants
    /// - Parameter url: location of the file containing the coded data
    private
    func decodeRestaurants( url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let restaurants = try decoder.decode([Restaurant].self, from: data)
        DispatchQueue.main.async {
            self.willChange.send(())
            self.restaurants = restaurants
        }
    }
    /// Attempt to download the current list of restaurants.
    ///
    /// Any failure will result in an attempt to read the restaurants from data cached during
    /// the last sucessful download.
    private
    func downloadRestaurants() {
        let restaurantsUrl = URL(string: serverName + restaurantName)
        download(name: restaurantName, url: restaurantsUrl!) {
            url in
            try self.decodeRestaurants(url: url)
        }
    }
    
    /// Fetch list of restaurants from our cache
    private
    func restaurantsFromCache() {
        dataFromCache(name: restaurantName) {
            url in
            try self.decodeRestaurants(url: url)
        }
    }

    // MARK: - Fetch scheduled rides
    
    /// Decode and update the list of rides
    /// - Parameter url: location of the local file containing coded ride info
    private
    func decodeRides(url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let rides = try decoder.decode([ScheduledRide].self, from: data)
        DispatchQueue.main.async {
            self.willChange.send(())
            self.rides = rides
            self.programState.cachedIndex = self.programState.selectedIndex
            ProgramState.store(self.programState)
        }

    }
    /// Fetch scheduled rides  from server
    private
    func downloadRides() {
        let year = programState.scheduleYears[programState.selectedIndex].year
        let fullName = serverName +
                        "schedule/" +
                        scheduleBase +
                        "-" +
                        year +
                        "." +
                        scheduleExt
        let scheduleUrl = URL(string: fullName)!
        download(name: scheduleName, url: scheduleUrl) {
            url in
            try self.decodeRides(url: url)
        }
    }
    
    /// Fetch scheduled rides from our cache
    private
    func ridesFromCache() {
        dataFromCache(name: scheduleName) {
            url in
            try self.decodeRides(url: url)
        }
    }

    // MARK: - Fetch trip descriptions

    private
    func decodeTrips(url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let trips = try decoder.decode([String : String].self, from: data)
        DispatchQueue.main.async {
            self.willChange.send(())
            self.trips = trips
        }
    }

    /// Fetch trip descriptions from server
    private
    func downloadTrips() {
        let tripUrl = URL(string: serverName + "schedule/" + tripName)!
        download(name: tripName, url: tripUrl) {
            url in
            try self.decodeTrips(url: url)
        }
    }

    private
    func tripsFromCache() {
        dataFromCache(name: tripName) {
            url in
            try self.decodeTrips(url: url)
        }
    }
}
