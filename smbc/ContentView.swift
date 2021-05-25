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

// MARK: - Main screen button styles

public struct SmbcButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title)
            .padding()
            .accentColor(.black)
            .background(Color.gray)
            .opacity(0.60)
            .cornerRadius(20)
    }
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

// MARK: - Initial Content

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @State var selection: Int? = nil
    @State private var infoPresented = false
    @State private var refreshPresented = false

    var model: Model
    var body: some View {
        NavigationView {
            VStack {
                Button(action: homePage) {
                    Text("""
                           Sunday Morning Breakfast Club
                           Breakfast and beyond since 1949
                           """)
                    .font(.headline)
                    .lineLimit(2)
                    .padding()
                }
                ZStack {
                    if model.rideModel.nextRide == nil {
                        NavigationLink(destination: RideView(),
                                       tag: 2,
                                       selection: $selection) { EmptyView() }
                    } else {
                        NavigationLink(destination: RideDetailView(ride: model.rideModel.nextRide!,
                                                                   year: model.rideModel.rideYear),
                                       tag: 1,
                                       selection: $selection) { EmptyView()}
                    }
                    SmbcImage()
                        .onTapGesture{ selection = model.rideModel.nextRide == nil ? 2 : 1 }
                        .onLongPressGesture {
                            refresh(model: model)
                            refreshPresented = true
                        }.alert(isPresented: $refreshPresented) { refreshAlert }

                }
                HStack {
                    Spacer()
                    NavigationLink("Restaurants", destination: RestaurantView())
                        .buttonStyle(SmbcButtonStyle())
                    Spacer()
                    NavigationLink("Rides", destination: RideView())
                        .buttonStyle(SmbcButtonStyle())
                    Spacer()
                }.padding()
             }.frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(backgroundGradient(colorScheme))
              .navigationBarTitle("SMBC")
              .navigationBarItems(trailing: info)
        }.environmentObject(model.rideModel)
         .environmentObject(model.restaurantModel)
         .environmentObject(model.tripModel)
    }
    
    var info: some View {
        Button(action: { self.infoPresented = true }) {
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

    var refreshAlert: Alert {
        Alert(title: Text("Data refresh"),
              message: Text("Current Trip, Restaurant, and Schedule data is being retrieved from smbc.snafu.org"),
              dismissButton: .default(Text("OK")))
    }

    private
    func homePage() {
        let url = URL(string: "https://smbc.snafu.org/")!
        UIApplication.shared.open(url)
    }

    // refresh model data from server
    private
    func refresh(model: Model) {
        model.tripModel = TripModel(refresh: true)
        model.restaurantModel = RestaurantModel(refresh: true)
        model.rideModel = RideModel(programState: model.rideModel.programState,
                                    refresh: true)
    }
}

struct SmbcImage: View {
    var body: some View {
        Image("smbc")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
            .padding(.horizontal)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var model = Model(savedState: ProgramState.load())

    static var previews: some View {
        ContentView(model: model)
    }
}
#endif
