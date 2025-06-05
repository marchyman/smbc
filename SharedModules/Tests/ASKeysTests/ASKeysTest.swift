//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation
import SwiftUI
import Testing

@testable import ASKeys

// serialized test to add a date to the @AppStorage in the first test
// and verify the date is available in the second

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
