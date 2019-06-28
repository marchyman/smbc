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

/// dictionary of trip descriptions.  The key is the first word of
/// the short description used in the schedule.
fileprivate let trips = [
    "Spring" :  """
                Spring ride to Death Valley. First group leaves at 5:00 AM. 2nd group leaves at 6:00AM. Route, groups, and every other detail subject to change.
                """,
    "Northern" : """
                Northern California River Ride.  Three nights moteling in Weaverville. Ride California's famed highways 36 and 299.
                """,
    "Nor" :     """
                Three nights camping at Hidden Springs near Myers Flat. Two days riding California's famed highways 3, 36 and 299.
                """,
    "GS" :      """
                GS style campout. A camping trip for those who want to see how well they and their bike can handle dirt roads. Destinations vary from year to year.
                """,
    "Gardnerville" : """
                Annual trek to the Carson City, Minden, Gardnerville region. Join us for dinner in Gardnerville, NV and the awarding of the boot.
                """,
    "Camping" : """
                Camping trip to Sequoia/Kings Canyon park. Spend one, two, or  three nights in Kings Canyon or the Sequoia National Park depending upon campsite availability.  Breakfast in Hollister at 8:15 Thrusday morning.
                """,
    "Sequoia" : """
                Camping trip to Sequoia/Kings Canyon park. Spend one, two, or three nights in Kings Canyon or the Sequoia National Park depending upon campsite availability.  Breakfast in Hollister at 8:15 Thursday morning.
                """,
    "Fall" :    """
                Fall ride to Death Valley. Some leave a day early.  Dates, times, and routes are usually discussed at breakfast a few weeks before the ride.
                """,
    "Paso" :    """
                Spring ride to Paso Robles for Sunday dinner at F. McClintocks.  Ride home on Monday.  Or extend the trip to suit your free time.
                """,
    "Patrick" : """
                Patrick's Point Campout. Sometimes it rains.  Sometimes it doesn't. Best to be prepared.
                """,
    "Sacramento" : """
                AFT Sacramento Mile. Ride up the delta roads Saturday to race fairgrounds. Stay the night at Fairfield Inn Cal Expo. Return Sunday.
                """,
    "Graeagle" : """
                Spend the night at the River Pines Resort cabins in Graeagle.  Dinner at Coyote Bar & Grill next door.
                """
]

struct TripView: View {
    var ride: ScheduledRide
    
    var body: some View {
        VStack {
            Text(tripText())
                .lineLimit(nil)
                .padding()
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity,
                minHeight: 0, maxHeight: .infinity)
         .background(LinearGradient(gradient: Gradient(colors: [.white, .gray, .white]), startPoint: .top, endPoint: .bottom), cornerRadius: 0)
         .navigationBarTitle(Text("\(ride.start) - \(ride.end!) Trip"))



    }
    
    private
    func tripText() -> String {
        if let spaceIndex = ride.description?.firstIndex(of: " ") {
            let key = String(ride.description![..<spaceIndex])
            if let trip = trips[key] {
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
