//
//  SmbcHelp.swift
//  smbc
//
//  Created by Marco S Hyman on 11/15/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
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

struct SmbcHelp: View {
    @State private var helpPresented = false

    var body: some View {
        Button(action: { helpPresented = true }) {
            Image(systemName: "questionmark.circle")
        }
        .alert(isPresented: $helpPresented) { smbcHelp }
    }

    var smbcHelp: Alert {
        Alert(title: Text("Application Help"),
              message: Text(
                """
                 Tap on the center image to show the next ride.

                 Long press on the center image to force schedule data refresh from the SMBC server.

                 Tap on the Restaurants button to list the restaurants the club visits.  You can look at all restaurants or the restaurants in current rotation.

                 Tap on the Rides button to list the rides for a schedule year.  Different years may be selected.  The schedule for the year of the next ride will always be loaded when returning to the home screen.

                 Tap on "Sunday Morning Breakfast Club" text to open a browser window to the SMBC web site home page.
                 """))
    }
}

struct SmbcHelp_Previews: PreviewProvider {
    static var previews: some View {
        SmbcHelp()
    }
}
