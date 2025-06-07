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

// the schedule in the app bundle is for this year.

let bundleYear = 2025

public enum ScheduleLoadStatus: Equatable, Sendable {
    case idle
    case loadPending
    case duplicateLoadPending
}

public struct ScheduleState: Equatable, Sendable {

    // the year of the loaded rides

    public var year: Int
    public var yearString: String {
        year.formatted(.number.grouping(.never))
    }

    // the models controlled by this state

    public var rideModel: RideModel
    public var tripModel: TripModel
    public var restaurantModel: RestaurantModel

    public var loadInProgress: ScheduleLoadStatus
    public var lastFetchError: String?
    public var nextRide: Ride?

    // the caches that hold the latest data
    let rideCache: Cache
    let tripCache: Cache
    let restaurantCache: Cache

    // optional URLs are used to inject test data

    public init(noGroup: Bool = false,
                rideURL: URL? = nil,
                tripURL: URL? = nil,
                restaurantURL: URL? = nil) {
        let initGroup: String? = noGroup ? nil : "group.org.snafu.smbc"
        let rideDataURL = rideURL ?? Self.bundleURL(for: Self.rideResource)
        let tripDataURL = tripURL ?? Self.bundleURL(for: Self.tripResource)
        let restaurantDataURL = restaurantURL ?? Self.bundleURL(for: Self.restaurantResource)

        year = bundleYear
        rideCache = Cache(name: Self.rideResource,
                          bundleURL: rideDataURL,
                          group: initGroup)
        rideModel = RideModel(cache: rideCache)

        tripCache = Cache(name: Self.tripResource,
                          bundleURL: tripDataURL,
                          group: initGroup)
        tripModel = TripModel(cache: tripCache)

        restaurantCache = Cache(name: Self.restaurantResource,
                                bundleURL: restaurantDataURL,
                                group: initGroup)
        restaurantModel = RestaurantModel(cache: restaurantCache)

        loadInProgress = .idle

        Logger(subsystem: "org.snafu", category: "ScheduleState")
            .info("Schedule state created for \(initGroup ?? "no group")")
    }
}

// ScheduleState static helper used during initialization
extension ScheduleState {

    // model resource names used to initialize the models
    public static let rideResource = "schedule.json"
    static let tripResource = "trips.json"
    public static let restaurantResource = "restaurants.json"

    static let scheduleServer = "https://smbc.snafu.org/"
    static let scheduleFolder = "schedule/"

    static func bundleURL(for resource: String) -> URL {
        let resourceElements = resource.split(separator: ".")
        let name = String(resourceElements[0])
        let ext = String(resourceElements[1])

        if let url = Bundle.module.url(forResource: name,
                                       withExtension: ext) {
            return url
        }
        fatalError("Missing Bundle Resource: \(resource)")
    }
}

// find the next ride

extension ScheduleState {

    // The  next breakfast ride on a date >=  todays  date

    public func getNextRide() -> Ride? {
        let monthDay: String
        guard
            let yesterday = Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: Date())
        else {
            return nil
        }
        let thisYear = Calendar.current.component(.year, from: yesterday)
        guard thisYear <= year else { return nil }
        if thisYear == year {
            let month = Calendar.current.component(.month, from: yesterday)
            let day = Calendar.current.component(.day, from: yesterday)
            monthDay = "\(month)/\(day)"
        } else {
            monthDay = "0/0"  // give me the first ride of schedYear
        }
        return rideModel.ride(following: monthDay)
    }
}

// extensions that help handle state change side effects

extension ScheduleState {
    func timeToFetch() -> Bool {
        @AppStorage(ASKeys.scheduleRefreshDate) var refreshDate = Date.distantPast
        return refreshDate < Date.now
    }

    func updateTimeFetched() {
        @AppStorage(ASKeys.scheduleRefreshDate) var refreshDate = Date.distantPast

        refreshDate = Calendar.current.date(
            byAdding: .day,
            value: 10,
            to: Date()) ?? Date()
        Logger(subsystem: "org.snafu", category: "ScheduleState")
            .notice("""
                \(ASKeys.scheduleRefreshDate, privacy: .public) set to \
                \(refreshDate, privacy: .public)
                """)
    }

    public nonisolated func fetchRides(for year: Int) async throws -> [Ride] {
        let yearSuffix = "-\(year)"

        let resourceElements = Self.rideResource.split(separator: ".")
        let name = String(resourceElements[0])
        let ext = String(resourceElements[1])
        let rideURL = URL(string: Self.scheduleServer +
                                  Self.scheduleFolder +
                                  name + yearSuffix + "." + ext)!
        let rideDownloader = Downloader(rideURL, cache: rideCache,
                                        decodeType: [Ride].self)
        let rides = try await rideDownloader.fetchJSON()
        return rides
    }

    public nonisolated func fetch(year: Int? = nil) async throws
    -> (year: Int, rides: [Ride], trips: [String: String],
        restaurants: [Restaurant]) {

        let rideYear = year ?? self.year
        async let rides = try await fetchRides(for: rideYear)

        let tripURL = URL(string: Self.scheduleServer +
                                  Self.scheduleFolder +
                                  Self.tripResource)!
        let tripDownloader = Downloader(tripURL, cache: tripCache,
                                        decodeType: [String: String].self)
        async let trips = try await tripDownloader.fetchJSON()

        let restaurantURL = URL(string: Self.scheduleServer +
                                        Self.restaurantResource)!
        let restaurantDownloader = Downloader(restaurantURL,
                                              cache: restaurantCache,
                                              decodeType: [Restaurant].self)
        async let restaurants = try await restaurantDownloader.fetchJSON()

        let results = try await (rideYear, rides, trips, restaurants)
        Logger(subsystem: "org.snafu", category: "ScheduleState")
            .info("rides, trips, and restaurants fetched")
        return results
    }
}

// actions that may cause state updates
public enum ScheduleAction: Equatable, Sendable {
    case fetchRequested(_ year: Int)
    case forcedFetchRequested
    case fetchResults(_ year: Int, _ rides: [Ride],
                      _ trips: [String: String], _ restaurants: [Restaurant])
    case fetchYearRequested(_ year: Int)
    case fetchYearResults(_ year: Int, _ rides: [Ride])
    case fetchError(_ error: String)
    case gotNextRide(_ ride: Ride?)
    case clearNextRide
}

public struct ScheduleReducer: Reducer {
    public init() {}

    public func reduce(_ state: ScheduleState,
                       _ action: ScheduleAction) -> ScheduleState {
        var newState = state

        let logger = Logger(subsystem: "org.snafu", category: "ScheduleReducer")
        switch action {
        case let .fetchRequested(year):
            logger.debug("Schedule fetch requested")
            switch state.loadInProgress {
            case .idle:
                if state.year != year || state.timeToFetch() {
                    logger.debug("load in progress")
                    newState.loadInProgress = .loadPending
                    // closure passed to Store send function must
                    // initiate the load
                }
            default:
                newState.loadInProgress = .duplicateLoadPending
            }

        case .forcedFetchRequested:
            logger.debug("Schedule forced fetch requested")
            switch state.loadInProgress {
            case .idle:
                logger.debug("load in progress")
                newState.loadInProgress = .loadPending
                // closure passed to Store send function must
                // initiate the load
            default:
                newState.loadInProgress = .duplicateLoadPending
            }

        case let .fetchResults(year, rides, trips, restaurants):
            logger.debug("Schedule fetch results")
            if newState.loadInProgress != .idle {
                newState.loadInProgress = .idle
                newState.year = year
                newState.rideModel.rides = rides
                newState.tripModel.trips = trips
                newState.restaurantModel.restaurants = restaurants
                newState.updateTimeFetched()
                newState.lastFetchError = nil
            } else {
                logger.error("Received load results when no load was in progress")
            }

        case let .fetchError(error):
            logger.debug("Schedule fetch error: \(error, privacy: .public)")
            if newState.loadInProgress != .idle {
                newState.loadInProgress = .idle
                newState.lastFetchError = error
            } else {
                logger.error("Received fetch error when no load was in progress")
            }

        case let .fetchYearRequested(year):
            logger.debug("Schedule fetch year: \(year, privacy: .public)")
            if newState.loadInProgress == .idle {
                logger.debug("load in progress")
                newState.loadInProgress = .loadPending
                // Store send closure will initiate the load
            } else {
                newState.loadInProgress = .duplicateLoadPending
            }

        case let .fetchYearResults(year, rides):
            logger.debug("Schedule year results for year: \(year, privacy: .public)")
            if newState.loadInProgress != .idle {
                newState.loadInProgress = .idle
                newState.year = year
                newState.rideModel.rides = rides
                newState.lastFetchError = nil
            } else {
                logger.error("Received load results when no load was in progress")
            }

        case let .gotNextRide(ride):
            let rideID = ride?.id ?? "none"
            logger.debug("Schedule next ride: \(rideID, privacy: .public)")
            newState.nextRide = ride

        case .clearNextRide:
            logger.debug("Schedule clearing nextRide")
            newState.nextRide = nil
        }

        return newState
    }
}
