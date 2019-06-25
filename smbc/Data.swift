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


/// Location and format of Restaurant data

fileprivate let serverName = "https://smbc.snafu.org/"
fileprivate let cacheFolderName = "Cache/org.snafu.smbc/"
fileprivate let restaurantName = "restaurants.json"
fileprivate let restaurantsUrl = URL(string: serverName + restaurantName)

struct Restaurant: Decodable {
    let id: String
    let name: String
    let address: String
    let city: String
    let phone: String
    let status: String
    let lat: Double
    let lon: Double
}

/// SMBCData holds all data needed for the app.  It is stored in the environment.

class SMBCData: BindableObject {
    let didChange = PassthroughSubject<Void, Never>()
    var restaurants = [Restaurant]()

    init() {
        getRestaurants()
        getSchedule()
    }

    /// Copy data returned from a network request to a cache
    ///
    /// - Parameter source: URL of data to be cached
    ///
    /// A cache folder inside the users Library will be created if necessary
    private
    func cacheRestaurants(source: URL) throws {
        let fileManager = FileManager.default
        let libraryDir = try fileManager.url(for: .libraryDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: true)
        let cacheFolder = libraryDir.appendingPathComponent(cacheFolderName)
        try fileManager.createDirectory(at: cacheFolder,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        let cachedFile = cacheFolder.appendingPathComponent(restaurantName)
        if fileManager.fileExists(atPath: cachedFile.path) {
            try? fileManager.removeItem(at: cachedFile)
        }
        try fileManager.copyItem(at: source, to: cachedFile)
    }

    private
    func restaurantsFromBundle() {
        //
    }

    private
    func restaurantsFromCache() {
        //
    }
    
    /// Attempt to download the current list of restaurants.
    ///
    /// Any failure will result in an attempt to read the restaurants from data cached during
    /// the last sucessful download.
    private
    func getRestaurants() {
        let task = URLSession.shared.downloadTask(with: restaurantsUrl!) {
            localURL, urlResponse, error in
            if let localURL = localURL {
                do {
                    try self.cacheRestaurants(source: localURL)
                    if let data = try? Data(contentsOf: localURL) {
                        let decoder = JSONDecoder()
                        self.restaurants = try decoder.decode([Restaurant].self, from: data)
                        self.didChange.send(())
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.restaurantsFromCache()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.restaurantsFromCache()
                }
            }
        }
        task.resume()
    }
    
    private
    func getSchedule() {
        //
    }
}
