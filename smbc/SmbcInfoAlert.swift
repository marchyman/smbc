//
//  SmbcInfo.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
//

import SwiftUI

// swiftlint:disable line_length

struct SmbcInfo: View {
    var body: some View {
        Button {
            infoPresented = true
        } label: {
            Image(systemName: "info.circle")
        }
        .alert(isPresented: $infoPresented) { smbcInfo }
    }

    var smbcInfo: Alert {
        Alert(title: Text("SMBC Information"),
              message: Text(
                """
                The Sunday Morning Breakfast Club is a loose affiliation of motorcycle riders who meet every Sunday for breakfast. We also plan 4 to 6 multi-day trips each year.

                Traditionally, riders meet at the corner of Laguna and Broadway in Burlingame with a full tank of gas in time to depart for breakfast at exactly 7:05.  Some still do.  Others meet at the destination restaurant.

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

// swiftlint:enable line_length
