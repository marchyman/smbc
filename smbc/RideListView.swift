//
//  RideView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
//

import SwiftUI

struct RideListView : View {
    @EnvironmentObject var state: ProgramState
    @State private var yearPickerPresented = false
    @State private var fetchFailed = false
    @State private var yearIndex = 0

    var body: some View {
        VStack {
            List (state.rideModel.rides) { ride in
                if ride.restaurant != nil {
                    RideRowView(ride: ride)
                }
                if ride.end != nil {
                    TripRowView(ride:ride)
                }
            }
            if state.nextRide != nil {
                NavigationLink("Show next ride",
                               destination: RideDetailView(ride: state.nextRide!))
                    .font(.title)
                    .padding(.bottom)
            }
        }
        .navigationTitle("SMBC Rides in \(state.yearString)")
        .navigationBarItems(trailing: Button(action: { yearPickerPresented = true } ) {
            Text("Change year")
                .font(.callout)
        })
        .alert(isPresented: $fetchFailed) {
             RefreshAlerts(type: .ride).type.view
        }
        .sheet(isPresented: $yearPickerPresented,
               onDismiss: fetchRideData) {
                YearPickerView(selectedIndex: $yearIndex)
        }
        .onAppear {
            yearIndex = state.yearModel.findYearIndex(for: state.year)
        }
    }

    /// If the user selected a different year fetch the schedule for that year
    func fetchRideData() {
        guard let year = Int(state.yearModel.scheduleYears[yearIndex].year)
        else {
            fetchFailed = true
            return
        }
        if year != state.year {
            Task {
                do {
                    try await state.rideModel.fetch(year: year)
                    state.year = year
                } catch {
                    fetchFailed = true
                }
            }
        }
    }
}

#if DEBUG
struct RideView_Previews : PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        NavigationStack {
            RideListView()
                .environmentObject(state)
        }
    }
}
#endif
