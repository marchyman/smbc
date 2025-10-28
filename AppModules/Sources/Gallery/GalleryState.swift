//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import ASKeys
import Cache
import Downloader
import Foundation
import OSLog
import SwiftUI
import UDF

// The store's state structure

public enum GalleryLoadStatus: Equatable, Sendable {
    case idle
    case loadPending
    case duplicateLoadPending
}

public struct GalleryState: Equatable, Sendable {
    var galleryModel: GalleryModel
    var loadInProgress: GalleryLoadStatus

    let galleryCache: Cache
    let galleryServer = "https://smbc.snafu.org/"

    public init(testCache: Cache? = nil) {
        galleryCache = testCache ??
        Cache(name: Self.galleryResource + ".json",
              bundleURL: Self.bundleURL(for: Self.galleryResource))
        galleryModel = GalleryModel(cache: galleryCache)
        loadInProgress = .idle
        Logger(subsystem: "org.snafu", category: "GalleryState")
            .info("Gallery state created")
    }
}

// static helper used during init
extension GalleryState {
    static let galleryResource = "gallery"

    static func bundleURL(for resource: String) -> URL {
        if let url = Bundle.module.url(forResource: resource,
                                       withExtension: "json") {
            return url
        }
        fatalError("Missing Bundle Resource: \(resource).json")
    }
}

// extensions that help handle state change side effects

extension GalleryState {
    func timeToFetch() -> Bool {
        @AppStorage(ASKeys.galleryRefreshDate) var refreshDate = Date.distantPast
        return refreshDate < Date.now
    }

    func updateTimeFetched() {
        @AppStorage(ASKeys.galleryRefreshDate) var refreshDate = Date.distantPast

        refreshDate = Calendar.current.date(
            byAdding: .day,
            value: 10,
            to: Date()) ?? Date()
        Logger(subsystem: "snafu.org", category: "GalleryState")
            .notice("""
                \(ASKeys.galleryRefreshDate, privacy: .public) set to \
                \(refreshDate, privacy: .public)
                """)
    }

    nonisolated func fetchNames() async throws -> [String] {
        let url = URL(string: galleryServer + Self.galleryResource + ".json")!
        let downloader = Downloader(url, cache: galleryCache, decodeType: [String].self)
        return try await downloader.fetchJSON()
    }
}

// Events that may cause the state to be updated

public enum GalleryEvent: Equatable, Sendable {
    case fetchRequested
    case forcedFetchRequested
    case fetchResults(_ entries: [String])
    case fetchError(_ error: String)
}

// All state updates occur here

public struct GalleryReducer: Reducer {
    public init() {}

    public func reduce(_ state: GalleryState, _ event: GalleryEvent) -> GalleryState {
        var newState = state

        let logger = Logger(subsystem: "snafu.org", category: "GalleryReducer")
        switch event {
        case .fetchRequested:
            logger.debug("gallery fetch requested")
            switch state.loadInProgress {
            case .idle:
                if state.timeToFetch() {
                    logger.debug("load in progress")
                    newState.loadInProgress = .loadPending
                    // closure passed to Store send function must
                    // initiate the load
                }
            default:
                newState.loadInProgress = .duplicateLoadPending
            }

        case .forcedFetchRequested:
            logger.debug("gallery forced fetch requested")
            switch state.loadInProgress {
            case .idle:
                newState.loadInProgress = .loadPending
                // closure passed to Store send function must
                // initiate the load
            default:
                newState.loadInProgress = .duplicateLoadPending
            }

        case let .fetchResults(entries):
            logger.debug("gallery fetch results")
            if newState.loadInProgress != .idle {
                newState.loadInProgress = .idle
                newState.galleryModel.names = entries
                newState.updateTimeFetched()
            } else {
                logger.error("""
                    Received load results when no load was in progress:
                    Entries -> \(entries, privacy: .public)
                    """)
            }
        case let .fetchError(error):
            logger.error("\(error)")
            if newState.loadInProgress != .idle {
                newState.loadInProgress = .idle
                // should perhaps save the error so it can be shown
                // to the user?
            } else {
                logger.error("Received fetch error when no load was in progress")
            }
        }

        return newState
    }
}
