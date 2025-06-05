//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import SwiftUI
import Testing

@testable import ASKeys

// serialized test to clear @AppStorage, add a date, then verify the
// date is available

let testDate = Date(timeIntervalSinceReferenceDate: 1_000_000)

@Suite(.serialized)
struct DateExtensionChecks {
    @Test func removeExisting() async throws {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    @Test func setDate() async throws {
        @AppStorage(ASKeys.galleryRefreshDate) var refreshDate = Date.distantPast
        #expect(refreshDate == Date.distantPast)
        refreshDate = testDate
    }

    @Test func checkDate() async throws {
        @AppStorage(ASKeys.galleryRefreshDate) var refreshDate = Date.distantPast
        #expect(refreshDate == testDate)
    }
}
