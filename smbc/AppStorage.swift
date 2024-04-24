//
//  AppStorage.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import Foundation

/// The schedule for a year is stored in the app bundle to initialize needed state before updated
/// data is downloaded from the SMBC server.
///
let bundleScheduleYear = 2024

// AppStorage keys

enum ASKeys {
    static let scheduleYear = "ScheduleYear"
    static let refreshDate = "RefreshDate"
    static let mapStyle = "MapStyle"
}

// Make Date RawRepresentable so they can be stored in AppStorage

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }

    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
