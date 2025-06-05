//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Cache
import Foundation

// Format of  restaurant records retrieved from server

public struct TripModel: Equatable, Sendable {
    public var trips: [String: String]

    public init(cache: Cache) {
        trips = cache.read(type: [String: String].self)
    }
}
