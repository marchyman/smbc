//
// Copyright 2019 Marco S Hyman
// https://www.snafu.org/
//

import Schedule
import SwiftUI
import UDF
import ViewModifiers

public struct RideListView: View {
    @Environment(Store<ScheduleState, ScheduleAction>.self) var store
    @State private var path: NavigationPath = .init()
    @State private var yearPickerPresented = false
    @State private var selectedYear: Int = 0

    public init() {}

    public var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List(store.rideModel.rides) { ride in
                    if ride.restaurant != nil {
                        RideRowView(ride: ride).id(ride.id)
                    } else if ride.description != nil {
                        TripRowView(ride: ride).id(ride.id)
                    }
                }
                .listStyle(.insetGrouped)
                .smbcBackground()
                .scrollContentBackground(.hidden)
                .refreshable { await fetch() }
                if let nextRide = store.state.getNextRide() {
                    NavigationLink(
                        "Show next ride",
                        destination: RideDetailView(ride: nextRide)
                    )
                    .buttonStyle(.bordered)
                    .padding(.bottom)
                } else {
                    Text("Not current year")
                        .padding(.bottom)
                }
            }
            .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)
            }
            .navigationTitle("SMBC Rides in \(store.yearString)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        yearPickerPresented.toggle()
                    } label: {
                        Text("Change year")
                            .font(.callout)
                    }
                }
            }
        }
        .sheet(isPresented: $yearPickerPresented,
               onDismiss: fetchSelectedYear) {
            YearPickerView(selectedYear: $selectedYear)
        }
        .onAppear {
            selectedYear = store.year
            if let nextRide = store.nextRide {
                store.send(.clearNextRide)
                path.append(nextRide)
            }
        }
    }

    func fetchSelectedYear() {
        if selectedYear != store.year {
            Task {
                await store.send(.fetchYearRequested(selectedYear)) {
                    if store.loadInProgress == .loadPending {
                        do {
                            let rides = try await store.state.fetchRides(for: selectedYear)
                            await store.send(.fetchYearResults(selectedYear, rides))
                        } catch {
                            await store.send(.fetchError(error.localizedDescription))
                        }
                    }
                }
            }
        }
    }

    func fetch() async {
        await store.send(.forcedFetchRequested) {
            if store.loadInProgress == .loadPending {
                do {
                    let (year, rides, trips, restaurants) = try await store.state.fetch()
                    await store.send(.fetchResults(year, rides, trips, restaurants))
                } catch {
                    await store.send(.fetchError(error.localizedDescription))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RideListView()
            .environment(Store(initialState: ScheduleState(noGroup: true),
                               reduce: ScheduleReducer(),
                               name: "Preview Schedule Store"))
    }
}
