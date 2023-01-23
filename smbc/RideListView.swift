//
//  RideView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/23/19.
//  Copyright © 2019, 2021 Marco S Hyman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: { yearPickerPresented = true } ) {
            Text("Change year")
                .font(.callout)
        })
        .alert(isPresented: $fetchFailed) {
             RefreshAlerts(type: .ride).type.view
        }
        .sheet(isPresented: $yearPickerPresented,
               onDismiss: fetchRideData) {
                YearPickerView(presented: $yearPickerPresented,
                               selectedIndex: $yearIndex)
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
