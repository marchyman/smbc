//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Cache
import Foundation

// format of a scheduled ride retrieved from server

public struct Ride: Decodable, Equatable, Sendable {
    public let start: String
    public let restaurant: String?
    public let end: String?
    public let description: String?
    public let comment: String?

    public init(start: String, restaurant: String?, end: String?,
                description: String?, comment: String?) {
        self.start = start
        self.restaurant = restaurant
        self.end = end
        self.description = description
        self.comment = comment
    }

    public var month: Int {
        Int(String(start.split(separator: "/")[0])) ?? 0
    }
    public var day: Int {
        Int(String(start.split(separator: "/")[1])) ?? 0
    }
}

extension Ride: Identifiable {
    public var id: String {
        var id = start + "-"
        if let restaurant {
            id += restaurant
        } else if let description {
            id += description.components(separatedBy: " ").first ?? "desc"
        } else {
            id += "unknown"
        }
        return id
    }
}

extension Ride: Hashable {}

public struct RideModel: Equatable, Sendable {
    public var rides: [Ride]

    public init(cache: Cache) {
        rides = cache.read(type: [Ride].self)
    }
}

// ride "navigation" functions. Find a ride before another ride, after another
// ride, after some date, etc.

extension RideModel {

    // ride following a given mm/dd.  trips are skipped

    public func ride(following start: String) -> Ride? {
         let date = start.split(separator: "/")
         let month = Int(String(date[0])) ?? 0
         let day = Int(String(date[1])) ?? 0
         guard
             let index = rides.firstIndex(where: {
                 ($0.month > month || ($0.month == month && $0.day > day))
                     && $0.restaurant != nil
             })
         else { return nil }
         return index < rides.endIndex ? rides[index] : nil
     }

     // return the ride following the given ride assuming one exists.
     // This function skips over trips.

     public func ride(following ride: Ride) -> Ride? {
         if let rideIndex = rides.firstIndex(of: ride) {
             var offset = 1
             while rideIndex + offset < rides.count {
                 if rides[rideIndex + offset].restaurant != nil {
                     return rides[rideIndex + offset]
                 }
                 offset += 1
             }
         }
         return nil
     }

     // return the ride preceding the given ride assuming one exists.
     // This functipn skips over trips.

     public func ride(preceding ride: Ride) -> Ride? {
         if let rideIndex = rides.firstIndex(of: ride) {
             var offset = 1
             while rideIndex - offset >= 0 {
                 if rides[rideIndex - offset].restaurant != nil {
                     return rides[rideIndex - offset]
                 }
                 offset += 1
             }
         }
         return nil
     }
}
