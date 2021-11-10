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

// MARK: - RideView -- list of rides for the year

struct RideListView : View {
    @EnvironmentObject var state: ProgramState
    @State private var yearPickerPresented = false

    var alert: Alert {
        Alert(title: Text("Schedule access error"),
              message: Text("""
                Schedule data for the desired year is not availalbe at this time.  There may be a network or server issue.

                Please try again, later.
                """),
              dismissButton: .default(Text("OK")))
    }

    var sheet: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    self.yearPickerPresented = false
                }.padding()
            }
            Text("Fix Later")
//            Picker("Pick desired year",
//                   selection: $rideModel.programState.selectedIndex) {
//                ForEach(0 ..< rideModel.programState.scheduleYears.count) {
//                    Text(self.rideModel.programState.scheduleYears[$0].year).tag($0)
//                }
//            }.pickerStyle(WheelPickerStyle())
//             .labelsHidden()
            Text("Pick desired year")
            Spacer()
        }
    }

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
        }.navigationBarTitle("SMBC Rides in \(state.year)")
         .navigationBarItems(trailing: Button("Change year") { self.yearPickerPresented = true })
         .sheet(isPresented: $yearPickerPresented,
                onDismiss: fetchRideData) { self.sheet }
//;;;         .alert(isPresented: $state.rideModel.fileUnavailable) { alert }
    }

    func fetchRideData() {
        Task {
            do {
                try await state.rideModel.fetch(year: state.year)
            } catch {
                //;;;
            }
        }
    }
}

#if DEBUG
struct RideView_Previews : PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        RideListView()
            .environmentObject(state)
    }
}
#endif
