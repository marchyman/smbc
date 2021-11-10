//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
//  Copyright © 2019, 2021 Marco S Hyman. All rights reserved.
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
    @State private var refreshPresented = false
    @State private var refreshFailed = false

    var state: ProgramState

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
                    if state.nextRide == nil {
                        NavigationLink(destination: RideListView(),
                                       tag: 2,
                                       selection: $selection) { EmptyView() }
                    } else {
                        NavigationLink(destination: RideDetailView(ride: state.nextRide!),
                                       tag: 1,
                                       selection: $selection) { EmptyView()}
                    }
                    SmbcImage()
                        .onTapGesture{ selection = state.nextRide == nil ? 2 : 1 }
                        .onLongPressGesture {
                            Task {
                                await refresh()
                                state.savedState.refreshTime = Date()
                                state.needRefresh = false
                            }
                            refreshPresented = true
                        }.alert(isPresented: $refreshPresented) { refreshAlert }
                }
                HStack {
                    Spacer()
                    NavigationLink("Restaurants", destination: RestaurantView())
                        .buttonStyle(SmbcButtonStyle())
                    Spacer()
                    NavigationLink("Rides", destination: RideListView())
                        .buttonStyle(SmbcButtonStyle())
                    Spacer()
                }.padding()
             }.frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(backgroundGradient(colorScheme))
              .navigationBarTitle("SMBC")
              .navigationBarItems(trailing: SmbcInfo())
              .alert(isPresented: $refreshFailed) {
                  RefreshFailure(alertType: .all).alertType.alertView
              }

        }
        .environmentObject(state)
    }

    var refreshAlert: Alert {
        Alert(title: Text("Data refresh"),
              message: Text(
                """
                Current Trip, Restaurant, and Schedule data is being retrieved from smbc.snafu.org

                It may take a few seconds for updated data to be received and processed.
                """),
              dismissButton: .default(Text("OK")))
    }

    private
    func homePage() {
        let url = URL(string: "https://smbc.snafu.org/")!
        UIApplication.shared.open(url)
    }

    // refresh model data from server
    private
    func refresh() async {
        do {
            try await state.yearModel.fetch()
            try await state.restaurantModel.fetch()
            try await state.rideModel.fetch(year: state.year)
            try await state.tripModel.fetch()
        } catch {
            refreshFailed = true
        }
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
    static var state = ProgramState()

    static var previews: some View {
        ContentView(state: state)
    }
}
#endif
