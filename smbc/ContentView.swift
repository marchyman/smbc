//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
//

import SwiftUI

func backgroundGradient(_ colorScheme: ColorScheme) -> LinearGradient {
    let color: Color = switch colorScheme {
                       case .light:
                            .white
                       case .dark:
                            .black
                       @unknown default:
                            fatalError("Unknown ColorScheme")
                       }
    return LinearGradient(gradient: Gradient(colors: [color, .gray, color]),
                          startPoint: .top,
                          endPoint: .bottom)
}

// MARK: - Initial Content

struct ContentView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @State var path = NavigationPath()

    @State private var noMoreRides = false

    // three state variables to control schedule data refreshing

    @State private var refreshPresented = false
    @State private var forceRefresh = false
    @State private var runRefreshTask = false

    // Button text and Navigation Link values
    let ridesKey = "Rides"
    let restaurantsKey = "Restaurants"

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                    Text("[Sunday Morning Breakfast Club\nBreakfast and beyond since 1949](https://smbc.snafu.org/)")
                    .font(.headline)
                    .lineLimit(2)
                    .padding()
                Spacer()
                SmbcImage()
                    .onTapGesture {
                        if let nextRide = state.rideModel.nextRide() {
                            path.append(ridesKey)
                            path.append(nextRide)
                        } else {
                            noMoreRides.toggle()
                        }
                    }
                    .onLongPressGesture {
                        refreshPresented = true
                        forceRefresh = true
                        runRefreshTask.toggle()
                    }
                Spacer()
                HStack {
                    NavigationLink(restaurantsKey, value: restaurantsKey)
                    Spacer()
                    NavigationLink(ridesKey, value: ridesKey)
                }
                .buttonStyle(SmbcButtonStyle())
                .padding(30)
            }
            .navigationDestination(for: String.self) { key in
                // key can only be ridesKey or restaurantsKey.  To simplify the
                // code assume anything not equal to ridesKey is restaurantsKey
                if key == ridesKey {
                    RideListView()
                } else {
                    RestaurantListView()
                }
            }
            .navigationDestination(for: ScheduledRide.self) { ride in
                RideDetailView(ride: ride)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient(colorScheme))
            .navigationTitle("SMBC")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack { SmbcHelp(); SmbcInfo() }
                }
            }
            .sheet(isPresented: $noMoreRides) {
                NoMoreRideView()
                    .presentationDetents([.medium])
            }
            .alert("Schedule Reload", isPresented: $refreshPresented) {
                // let the system provide the button
            } message: {
                // swiftlint:disable line_length
                Text("""
                     Up to date Trip, Restaurant, and Schedule data is being retrieved from smbc.snafu.org

                     It may take a few seconds for the updated data to be received and processed.
                     """)
                // swiftlint:enable line_length
            }
            .task(id: runRefreshTask) {
                await refresh()
            }
        }
    }

    /// refresh model data from server when necessary
    ///
    /// Refresh rules:
    /// 1) Refresh when asked due to a long press on SmbcImage
    /// 2) Refresh when the current date is greater than the refreshDate
    /// 3) Refresh for the following year when there are no more rides for the year
    /// 4) Refresh when the current schedule is not loaded.  Handle the case where
    ///   the current date is the end of the year
    private
    func refresh() async {
        @AppStorage(ASKeys.refreshDate) var refreshDate = Date()
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear

        var needRefresh = false
        let today = Date()
        var year = Calendar.current.component(.year, from: today)

        if forceRefresh {
            forceRefresh = false
            needRefresh = true
        } else if today > refreshDate {
            needRefresh = true
        } else if year == scheduleYear && state.rideModel.nextRide() == nil {
            year += 1
            needRefresh = true
        } else {
            let weekOfYear = Calendar.current.component(.weekOfYear, from: today)
            if weekOfYear <= 52 && year != scheduleYear {
                needRefresh = true
            }
        }
        if needRefresh {
            do {
                try await state.refresh(year)
            } catch FetchError.yearModelError {
//                alertView = RefreshAlerts(type: .year).type.view
//                refreshPresented = true
            } catch FetchError.restaurantModelError {
//                alertView = RefreshAlerts(type: .restaurant).type.view
//                refreshPresented = true
            } catch FetchError.rideModelError {
//                alertView = RefreshAlerts(type: .ride).type.view
//                refreshPresented = true
            } catch FetchError.tripModelError {
//                alertView = RefreshAlerts(type: .trip).type.view
//                refreshPresented = true
            } catch {
//                alertView = RefreshAlerts(type: .all).type.view
//                refreshPresented = true
            }
        }
    }
}

struct SmbcImage: View {
    var body: some View {
        Image(.smbc)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
            .padding(.horizontal)
    }
}

// MARK: - Main screen button styles

public struct SmbcButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 120)
            .font(.title2)
            .foregroundColor(.blue)
            .padding()
            .accentColor(.black)
            .background(Color.gray.opacity(0.25))
            .cornerRadius(20)
    }
}

#Preview {
    let state = ProgramState()

    return ContentView()
        .environment(state)
}
