//
//  FetchError.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import Foundation

/// Data fetching error types
///
enum FetchError: Error {
    case yearModelError
    case restaurantModelError
    case rideModelError
    case tripModelError
    case galleryError
}

extension FetchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .yearModelError:
            return "Failed to fetch list of available schedules"
        case .restaurantModelError:
            return "Failed to fetch Restaurant information"
        case .rideModelError:
            return "Failed to fetch Ride information"
        case .tripModelError:
            return "Failed to fetch Trip information"
        case .galleryError:
            return "Failed to fetch gallery information"
        }
    }
}
