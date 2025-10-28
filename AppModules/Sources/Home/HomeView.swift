//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Schedule
import SwiftUI
import UDF
import ViewModifiers

public struct HomeView: View {
    @Environment(Store<ScheduleState, ScheduleAction>.self) var store
    @State private var reloadingPresented = false
    @State private var noMoreRides = false
    @State var showLog = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack {
                Text(
                    """
                    [Sunday Morning Breakfast Club\nBreakfast and beyond \
                    since 1949](https://smbc.snafu.org/)
                    """)
                    .font(.headline)
                    .lineLimit(2)
                    .padding()
                    .onLongPressGesture {
                        showLog = true
                    }
                    .accessibilityIdentifier("smbc link")
                Spacer()
                SmbcImage()
                .onTapGesture {
                    showNextRide()
                }
                .onLongPressGesture {
                    Task {
                        reloadingPresented.toggle()
                        await fetch(forced: true)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .smbcBackground()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("SMBC")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        SmbcHelp()
                            .accessibilityIdentifier("help")
                        SmbcInfo()
                            .accessibilityIdentifier("info")
                    }
                }
            }
            .alert("Reloading", isPresented: $reloadingPresented) {
                // system provides a button to dismiss
            } message: {
                Text("""
                        Up to date Trip, Restaurant, and Schedule data \
                        is being retrieved from smbc.snafu.org.

                        It may take a few seconds for the updated data to \
                        be received and processed.
                        """)
            }
            .alert("Last Ride", isPresented: $noMoreRides) {
                // system provides a button to dismiss
            } message: {
                NoMoreRideView()
            }
            .sheet(isPresented: $showLog) {
                LogView()
            }
            .onAppear {
                Task { await fetch() }
            }
            .onOpenURL { url in
                guard url.scheme == "smbc" else { return }
                showNextRide()
            }
        }
    }

    func showNextRide() {
        if ProcessInfo.processInfo.environment["NONEXTRIDE"] != nil {
            noMoreRides.toggle()
        } else {
            if let nextRide = store.state.getNextRide() {
                store.send(.gotNextRide(nextRide))
            } else {
                noMoreRides.toggle()
            }
        }
    }

    func fetch(forced: Bool = false) async {
        // fetch ride info for the year of the next ride.  The last week
        // of the year that will be the schedule for the following year.

        var year = Calendar.current.component(.year, from: .now)
        if year == store.year && store.state.getNextRide() == nil {
            year += 1
        }
        let action = forced ? ScheduleAction.forcedFetchRequested : .fetchRequested(year)
        await store.send(action) {
            if store.loadInProgress == .loadPending {
                do {
                    let (year, rides, trips, restaurants) = try await store.state.fetch(year: year)
                    await store.send(.fetchResults(year, rides, trips, restaurants))
                } catch {
                    store.send(.fetchError(error.localizedDescription))
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(Store(initialState: ScheduleState(noGroup: true),
                           reduce: ScheduleReducer()))
}
