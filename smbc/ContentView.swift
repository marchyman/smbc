//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
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

public struct SmbcButtonStyle: ButtonStyle {
    public func body(configuration: Button<Self.Label>, isPressed: Bool) -> some View {
        configuration
            .accentColor(.black)
            .padding()
            .background(Color.gray)
            .opacity(0.60)
            .cornerRadius(20)
    }
}

extension StaticMember where Base : ButtonStyle {
//    public static var smbc: SmbcButtonStyle.Member {
//        StaticMember<SmbcButtonStyle>(SmbcButtonStyle())
//    }
// or
    public static var smbc: StaticMember<SmbcButtonStyle> {
        return .init(SmbcButtonStyle())
    }
// I don't know which is preferred
}

func backgroundGradient(_ colorScheme: ColorScheme) -> LinearGradient {
    let color: Color
    switch colorScheme {
    case .light:
        color = .white
    case .dark:
        color = .black
    @unknown default:
        fatalError("Unknown ColorScheme")
    }
    return LinearGradient(gradient: Gradient(colors: [color, .gray, color]),
                          startPoint: .top,
                          endPoint: .bottom)
}


struct ContentView : View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject var smbcData: SMBCData
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Text("""
                     Sunday Morning Breakfast Club
                     Breakfast and beyond since 1949
                     """)
                    .font(.body)
                    .lineLimit(2)
                    .padding()
                Image("smbc")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .padding(.leading)
                    .padding(.trailing)
                HStack {
                    Spacer()
                    NavigationLink(destination: RestaurantView().environmentObject(smbcData)) {
                        Text("Restaurants").font(.title)
                    }.buttonStyle(.smbc)
                    Spacer()
                    NavigationLink(destination: RideView().environmentObject(smbcData)) {
                        Text("Rides").font(.title)
                    }.buttonStyle(.smbc)
                    Spacer()
                }.padding()
             }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
              .background(backgroundGradient(colorScheme), cornerRadius: 0)
              .navigationBarTitle(Text("SMBC"))
              .navigationBarItems(trailing: Button(action: { self.showingAlert = true }) {
                    Image(systemName: "info.circle")
                        .presentation($showingAlert, alert: smbcInfo)
                })
        }
    }
    
    private
    func smbcInfo() -> Alert {
        Alert(title: Text("SMBC Information"),
              message: Text(
                """
                The Sunday Morning Breakfast Club is a loose affiliation of motorcycle riders who meet every Sunday for breakfast. We also have 4-6 longer trips planned each year.
                        
                Traditionally, riders met at the corner of Laguna and Broadway in Burlingame in time to depart for breakfast at exactly 7:05.  Some still do.  Others meet at the destination restaurant.

                After breakfast some go home while others ride bay area back roads. Routes are decided in the gab fest that follows breakfast.

                We make it easy to join the club: show up for breakfast and you are a member; stop showing up to quit. You can ride every weekend, a few times a year, or only on multi-day rides.
                """),
              dismissButton: .default(Text("Got It!")))
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
