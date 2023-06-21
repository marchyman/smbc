//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
//

import SwiftUI

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
    @EnvironmentObject var state: ProgramState
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @State var path = NavigationPath()

    @State private var noMoreRides = false
    @State private var refreshPresented = false
    @State private var alertView = RefreshAlerts(type: .refreshing).type.view

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
                        if let nextRide = state.nextRide {
                            path.append(ridesKey)
                            path.append(nextRide)
                        } else {
                            noMoreRides.toggle()
                        }
                    }
                    .onLongPressGesture {
                        state.needRefresh = true
                        alertView = RefreshAlerts(type: .refreshing).type.view
                        refreshPresented = true
                        refresh()
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
                    RestaurantView()
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
            .alert(isPresented: $refreshPresented) { alertView }
            .onAppear {
                refresh()
            }
        }
    }

    /// refresh model data from server when necessary
    ///
    private
    func refresh() {
        let today = Date()
        var year = Calendar.current.component(.year, from: today)
        let weekOfYear = Calendar.current.component(.weekOfYear, from: today)

        // If the loaded schedule isn't current load the appropriate schedule.
        // If the schedule is current but there are no more rides load the
        // schedule for the following year if it exists.
        if (weekOfYear <= 52 && year != state.year) ||
            state.nextRide == nil {
            if year == state.year {
                year += 1
            }
            state.needRefresh = state.yearModel.scheduleExists(for: year)
        }
        // alway try a refresh here as state.needRefresh may have been
        // set elsewhere.
        Task {
            do {
                try await state.refresh(year)
            } catch FetchError.yearModelError {
                alertView = RefreshAlerts(type: .year).type.view
                refreshPresented = true
            } catch FetchError.restaurantModelError {
                alertView = RefreshAlerts(type: .restaurant).type.view
                refreshPresented = true
            } catch FetchError.rideModelError {
                alertView = RefreshAlerts(type: .ride).type.view
                refreshPresented = true
            } catch FetchError.tripModelError {
                alertView = RefreshAlerts(type: .trip).type.view
                refreshPresented = true
            } catch {
                alertView = RefreshAlerts(type: .all).type.view
                refreshPresented = true
            }
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

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var state = ProgramState()

    static var previews: some View {
        ContentView().environmentObject(state)
    }
}
#endif
