//
//  SmbcInfo.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//

import SwiftUI

/// View containing a buttom that when pressed displays some generic information about the SMBC
/// 
struct SmbcInfo: View {
    @State private var infoPresented = false
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

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

                 SMBC App Version \(appVersion != nil ? appVersion! : "Unknown")
                 """),
              dismissButton: .default(Text("Got It!")))
    }

}

struct SmbcInfoAlert_Previews: PreviewProvider {
    static var previews: some View {
        SmbcInfo()
    }
}
