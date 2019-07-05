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
fileprivate let cacheFolderName = "Cache/org.snafu.smbc/"
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
    let didChange = PassthroughSubject<Void, Never>()
    var restaurants = [Restaurant]()
    var rides = [ScheduledRide]()
    var trips = [String:String]()
    
    var years = [String]()      // Array of years for which scheduled ride data was found
    var yearIndex = 0           // index into the above array for the current year
    var year: String {          // shortcut to return the current year
        years[yearIndex]
    }
    var yearUpdated = false {   // toggled to force load of rides array for appropriate year.
        didSet {
            getRides(year: year)
        }
    }

    init() {
        let yearFormat = DateFormatter()
        yearFormat.dateFormat = "y"
        years.append(yearFormat.string(from: Date()))
        
        getRestaurants()
        getRides(year: year)
        getTrips()
        checkRides(year: year, previous: true)
        checkRides(year: year, previous: false)
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
        guard var index = rides.firstIndex(where: { $0.start == start }) else {
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
    /// - Parameter name: Name of file inside of cache folder
    ///
    /// A cache folder inside the users Library will be created if necessary
    private
    func cacheData(source: URL, name: String) throws {
        let fileManager = FileManager.default
        let libraryDir = try fileManager.url(for: .libraryDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: true)
        let cacheFolder = libraryDir.appendingPathComponent(cacheFolderName)
        try fileManager.createDirectory(at: cacheFolder,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        let cachedFile = cacheFolder.appendingPathComponent(name)
        if fileManager.fileExists(atPath: cachedFile.path) {
            try? fileManager.removeItem(at: cachedFile)
        }
        try fileManager.copyItem(at: source, to: cachedFile)

    }
    
    private
    func dataFromCache(name: String, reader: @escaping (URL) throws -> ()) {
        let fileManager = FileManager.default
        do {
            let libraryDir = try fileManager.url(for: .libraryDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil,
                                                 create: false)
            let cacheFolder = libraryDir.appendingPathComponent(cacheFolderName)
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
            fatalError("Cannot find list of restaurants")
        }
    }

    // MARK: - download data using a URLSession
    
    /// Download and process data using a URLSession
    /// - Parameter name: name of the file to download  used for caching the results
    /// - Parameter url: URL of the file to download
    /// - Parameter reader: function to call to process the downloaded data
    ///
    ///
    private
    func download(name: String,
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
                    self.dataFromCache(name: name, reader: reader)
                }
            } else {
                self.dataFromCache(name: name, reader: reader)
            }
        }.resume()
    }

    // MARK: - Get list of restaurants

    /// Attempt to download the current list of restaurants.
    ///
    /// Any failure will result in an attempt to read the restaurants from data cached during
    /// the last sucessful download.
    private
    func getRestaurants() {
        let restaurantsUrl = URL(string: serverName + restaurantName)
        download(name: restaurantName, url: restaurantsUrl!) {
            url in
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.restaurants = try decoder.decode([Restaurant].self, from: data)
            DispatchQueue.main.async {
                self.didChange.send(())
            }
        }
    }

    // MARK: - Get scheduled rides

    
    /// Fetch rides for the give year from server
    /// - Parameter year: The year of the schedule to fetch
    private
    func getRides(year: String) {
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
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.rides = try decoder.decode([ScheduledRide].self, from: data)
            DispatchQueue.main.async {
                self.didChange.send(())
            }
        }
    }

    // MARK: - Check for existence of schedules for previous or following year
    
    /// Check if scheduled ride data exists
    /// - Parameter year: The year before/after the year to check
    /// - Parameter previous: if true then check the year before the given year, otherwise the year after
    ///
    /// Keep recursing until scheduled data is not found, then signal that smbcData has changed.
    private
    func checkRides(year: String, previous: Bool) {
        if var intYear = Int(year) {
            if previous {
                intYear -= 1
            } else {
                intYear += 1
            }
            let newYear = String(intYear)
            let fullName = serverName +
                            "schedule/" +
                            scheduleBase +
                            "-" +
                            newYear +
                            "." +
                            scheduleExt
            let scheduleUrl = URL(string: fullName)!
            URLSession.shared.downloadTask(with: scheduleUrl) {
                localURL, urlResponse, error in
                if let response = urlResponse as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) {
                    DispatchQueue.main.async {
                        self.years.append(newYear)
                        self.checkRides(year: newYear, previous: previous)
                    }
                } else {
                    DispatchQueue.main.async {
//                      self.years.sort()
                        self.didChange.send(())
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Get list of trip descriptions
    
    /// Fetch trip descriptions from server
    private
    func getTrips() {
        let tripUrl = URL(string: serverName + "schedule/" + tripName)!
        download(name: tripName, url: tripUrl) {
            url in
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.trips = try decoder.decode([String : String].self, from: data)
            DispatchQueue.main.async {
                self.didChange.send(())
            }
        }
    }
}
