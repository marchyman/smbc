//
//  TripModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//

import Foundation
import Observation

@MainActor
@Observable
final class TripModel {
    var trips = [String: String]()

    /// Initialize list of restaurants from the cache
    ///
    init() {
        let cache = Cache(name: tripFileName, type: [String: String].self)
        trips = cache.cachedData()
    }

    /// fetch current data from the server  and update the model.
    ///
    func fetch() async throws {
        let url = URL(string: serverName + serverDir + tripFileName)!
        trips = try await Downloader.fetch(
            name: tripFileName,
            url: url,
            type: [String: String].self
        )
    }

}
