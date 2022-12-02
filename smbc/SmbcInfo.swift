//
//  SmbcInfo.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
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

/// View containing a buttom that when pressed displays some generic information about the SMBC
/// 
struct SmbcInfo: View {
    @State private var infoPresented = false

    var body: some View {
        Button(action: { self.infoPresented = true }) {
            Image(systemName: "info.circle")
        }
        .alert(isPresented: $infoPresented) { smbcInfo }
    }

    var smbcInfo: Alert {
        Alert(title: Text("SMBC Information"),
              message: Text(
                """
                 The Sunday Morning Breakfast Club is a loose affiliation of motorcycle riders who meet every Sunday for breakfast. We also plan several multi-day trips each year.

                 Traditionally, riders met at the corner of Laguna and Broadway in Burlingame with a full tank of gas in time to depart for breakfast at exactly 7:05.  A few still do.  Most meet at the destination restaurant.

                 After breakfast some go home while others ride bay area back roads. Ride routes are decided in the gab fest that follows breakfast.

                 We make it easy to join the club: show up for breakfast and you are a member. Stop showing up to quit. You can ride every weekend, a few times a year, or only on multi-day rides.
                 """),
              dismissButton: .default(Text("Got It!")))
    }

}

struct SmbcInfoAlert_Previews: PreviewProvider {
    static var previews: some View {
        SmbcInfo()
    }
}
