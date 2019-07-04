//
//  TripView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/27/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
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

import Foundation
import SwiftUI

struct TripView: View {
    @EnvironmentObject var smbcData: SMBCData
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    var ride: ScheduledRide
    
    var body: some View {
        VStack {
            Text(tripText())
                .lineLimit(nil)
                .padding()
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity,
                minHeight: 0, maxHeight: .infinity)
         .background(backgroundGradient(colorScheme), cornerRadius: 0)
         .navigationBarTitle(Text("\(ride.start) - \(ride.end!) Trip"))
    }
    
    private
    func tripText() -> String {
        if let spaceIndex = ride.description?.firstIndex(of: " ") {
            let key = String(ride.description![..<spaceIndex])
            if let trip = smbcData.trips[key] {
                return trip
            }

        }
        return """
                Sorry!

                I don't have any information about
                \(ride.description!)
                """
    }
}

#if DEBUG
struct tripView_Previews : PreviewProvider {
    static var previews: some View {
        TripView(ride: ScheduledRide(start: "7/12",
                                     restaurant: nil,
                                     end: "7/13",
                                     description: "Graegle blah",
                                     comment: "preview"))
    }
}
#endif
