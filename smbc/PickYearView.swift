//
//  PickYearView.swift
//  smbc
//
//  Created by Marco S Hyman on 7/16/19.
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

import SwiftUI

// MARK: -- Pick a schedule year

/// I don't want to force a fetch of data from the server every time the picker wheel is modified.
/// Better if I wait until the few is about to go away and then cause the model to fetch needed
/// data and signal that the model has changed once the data has been received.
/// Alas, onDisappear is not called for navigation events.  I don't know if that is part of the design
/// or a beta bug.
///
/// I am triggering the update using the done button.  But... button use is optional... the user
/// could swipe the view away, instead.  This is a bug that needs to be resolved.
///
struct PickYearView : View {
    @EnvironmentObject var smbcData: SMBCData
    
    var body: some View {
        VStack {
            Picker(selection: $smbcData.yearIndex,
                   label: Text("Please select a schedule year")) {
                    ForEach(0 ..< smbcData.years.count) {
                        Text(self.smbcData.years[$0]).tag($0)
                    }
            }
            Group {
                Text("Pick the desired year")
                Text("Swipe down to return to schedule")
            }.padding()
             .foregroundColor(.orange)
            
        }
    }
}

#if DEBUG
struct PickYearView_Previews : PreviewProvider {
    static var previews: some View {
        PickYearView()
    }
}
#endif
