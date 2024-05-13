//
//  SmbcHelp.swift
//  smbc
//
//  Created by Marco S Hyman on 11/15/21.
//

import SwiftUI

struct SmbcHelp: View {
    @State private var helpPresented = false

    var body: some View {
        Button {
            helpPresented = true
        } label: {
            Image(systemName: "questionmark.circle")
        }
        .alert("Application Help", isPresented: $helpPresented) {
            // let system provide the button
        } message: {
            // swiftlint:disable line_length
            Text("""
                Tap on the center image to show the next ride.

                Long press on the center image to refresh schedule data from the SMBC server.

                Tap on "Sunday Morning Breakfast Club" text to open a browser window to the SMBC web site home page.

                Select the Restaurants tab to list the restaurants the club visits.  You can look at all restaurants or the restaurants in current rotation.

                Select the Rides tab to list the rides for a schedule year. Other years may be selected from the list of rides. The schedule for the year of the next ride will always be loaded when returning to the home screen.

                When viewing rides you can swipe left/right to look at the next/previous ride. A tap on the restaurant location marker will toggle look-around.  Look-around data is not always available.
                """)
            // swiftlint:enable line_length
        }
    }
}

#Preview {
    SmbcHelp()
}
