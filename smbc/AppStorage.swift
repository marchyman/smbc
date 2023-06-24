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
let bundleScheduleYear = 2023

// AppStorage keys

enum ASKeys {
    static let scheduleYear = "ScheduleYear"
    static let refreshDate = "RefreshDate"
}

// Make Date RawRepresentable so they can be stored in AppStorage

extension Date: RawRepresentable {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    public var rawValue: String {
        Date.dateFormatter.string(from: self)
    }

    public init?(rawValue: String) {
        self = Date.dateFormatter.date(from: rawValue) ?? Date()
    }
}
