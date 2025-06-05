//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation

public enum ASKeys {
    public static let galleryRefreshDate = "GalleryRefreshDate"
    public static let mapStyle = "MapStyle"
    public static let scheduleRefreshDate = "ScheduleRefreshDate"
}

// Make Date RawRepresentable so they can be stored in AppStorage

extension Date: @retroactive RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }

    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
