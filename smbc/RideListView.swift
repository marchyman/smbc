//
//  RideView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
//

import SwiftUI

struct RideListView: View {
    @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Binding var viewState: ViewState
    @State private var yearPickerPresented = false
    @State private var fetchFailed = false
    @State private var yearIndex = 0

    var body: some View {
        NavigationStack(path: $viewState.path) {
            VStack {
                List(state.rideModel.rides) { ride in
                    if ride.restaurant != nil {
                        RideRowView(ride: ride).id(ride.id)
                    } else if ride.description != nil {
                        TripRowView(ride: ride).id(ride.id)
                    }
                }
                if let nextRide = state.rideModel.nextRide() {
                    NavigationLink("Show next ride",
                                   destination: RideDetailView(ride: nextRide))
                        .buttonStyle(.bordered)
                        .padding(.bottom)
                }
            }
            .background(backgroundGradient(colorScheme))
            .navigationDestination(for: ScheduledRide.self) { ride in
                RideDetailView(ride: ride)
            }
            .navigationTitle("SMBC Rides in \(state.scheduleYearString)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        yearPickerPresented = true
                    } label: {
                        Text("Change year")
                            .font(.callout)
                    }
                }
            }
        }
        .alert("Schedule Reload Error", isPresented: $fetchFailed) {
            // let the system provide the button
        } message: {
            ReloadErrorView(description: "Failed to fetch ride data for selected year")
        }
        .sheet(isPresented: $yearPickerPresented,
               onDismiss: fetchRideData) {
                YearPickerView(selectedIndex: $yearIndex)
        }
        .onAppear {
            yearIndex = state.yearModel.findYearIndex(for: scheduleYear)
            if let nextRide = viewState.nextRide {
                viewState.nextRide = nil
                viewState.path.append(nextRide)
            }
        }
    }

    /// If the user selected a different year fetch the schedule for that year
    @MainActor
    func fetchRideData() {
        guard let selectedYear = Int(state.yearModel.scheduleYears[yearIndex].year)
        else {
            fetchFailed = true
            return
        }
        if selectedYear != scheduleYear {
            Task {
                do {
                    try await state.rideModel.fetch(scheduleFor: selectedYear)
                } catch {
                    fetchFailed = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RideListView(viewState: .constant(ViewState()))
            .environment(ProgramState())
    }
}
