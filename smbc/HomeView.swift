//
//  HomeView.swift
//  smbc
//
//  Created by Marco S Hyman on 4/25/24.
//  Copyright © 2024 Marco S Hyman. All rights reserved.
//

import SwiftUI

@MainActor
struct HomeView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    var viewState = ViewState.shared

    @State private var noMoreRides = false
    @State private var runRefreshTask = false
    @State private var forceRefresh = false
    @State private var refreshPresented = false
    @State private var refreshError: String = ""
    @State private var refreshErrorPresented = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("[Sunday Morning Breakfast Club\nBreakfast and beyond since 1949](https://smbc.snafu.org/)")
                    .font(.headline)
                    .lineLimit(2)
                    .padding()
                Spacer()
                SmbcImage()
                    .onTapGesture {
                        if let nextRide = state.rideModel.nextRide() {
                            viewState.nextRide = nextRide
                            viewState.selectedTab = .rides
                        } else {
                            noMoreRides.toggle()
                        }
                    }
                    .onLongPressGesture {
                        refreshPresented = true
                        forceRefresh = true
                        runRefreshTask.toggle()
                    }
                Spacer()
            }
            .background(backgroundGradient(colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("SMBC")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack { SmbcHelp(); SmbcInfo() }
                }
            }
            .alert("Schedule Reload", isPresented: $refreshPresented) {
                // let the system provide the button
            } message: {
                ScheduleReloadView()
            }
            .alert("Schedule Reload Error",
                   isPresented: $refreshErrorPresented) {
                // let the system provide the button
            } message: {
                ReloadErrorView(description: refreshError)
            }
            .sheet(isPresented: $noMoreRides) {
                NoMoreRideView()
                    .presentationDetents([.medium])
            }
            .task(id: runRefreshTask) {
                await refresh()
            }
        }
    }

    /// refresh model data from server when necessary
    ///
    /// Refresh rules:
    /// 1) Refresh when asked due to a long press on SmbcImage
    /// 2) Refresh when the current date is greater than the refreshDate
    /// 3) Refresh for the following year when there are no more rides for the year
    /// 4) Refresh when the current schedule is not loaded.  Handle the case where
    ///   the current date is the end of the year
    @MainActor
    private func refresh() async {
        @AppStorage(ASKeys.refreshDate) var refreshDate = Date()
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear

        var needRefresh = false
        let today = Date()
        var year = Calendar.current.component(.year, from: today)

        if forceRefresh {
            forceRefresh = false
            needRefresh = true
        } else if today > refreshDate {
            needRefresh = true
        } else if year == scheduleYear && state.rideModel.nextRide() == nil {
            year += 1
            needRefresh = true
        } else {
            let weekOfYear = Calendar.current.component(.weekOfYear, from: today)
            if weekOfYear <= 52 && year != scheduleYear {
                needRefresh = true
            }
        }
        if needRefresh {
            do {
                try await state.refresh(year)
            } catch let error {
                refreshError = error.localizedDescription
                refreshErrorPresented.toggle()
            }
        }
    }
}

#Preview {
    HomeView()
}
