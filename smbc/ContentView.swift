//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
//

import SwiftUI

enum TabItems {
    case home
    case restaurants
    case rides
}

// MARK: - Initial Content

struct ContentView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Binding var viewState: ViewState

    var body: some View {
        TabView(selection: $viewState.selectedTab) {
            HomeView(viewState: viewState)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(TabItems.home)

            RestaurantListView()
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }
                .tag(TabItems.restaurants)

            RideListView(viewState: $viewState)
                .tabItem {
                    Label("Rides", systemImage: "map")
                }
                .tag(TabItems.rides)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $viewState.noMoreRides) {
            NoMoreRideView()
                .presentationDetents([.medium])
        }
        .alert("Schedule Reload", isPresented: $viewState.refreshPresented) {
            // let the system provide the button
        } message: {
            ScheduleReloadView()
        }
        .alert("Schedule Reload Error",
               isPresented: $viewState.refreshErrorPresented) {
            // let the system provide the button
        } message: {
            ReloadErrorView(description: viewState.refreshError)
        }
        .task(id: viewState.runRefreshTask) {
            await refresh()
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
    @MainActor
    private func refresh() async {
        @AppStorage(ASKeys.refreshDate) var refreshDate = Date()
        @AppStorage(ASKeys.scheduleYear) var scheduleYear = bundleScheduleYear

        var needRefresh = false
        let today = Date()
        var year = Calendar.current.component(.year, from: today)

        if viewState.forceRefresh {
            viewState.forceRefresh = false
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
            } catch let error {
                viewState.refreshError = error.localizedDescription
                viewState.refreshErrorPresented.toggle()
            }
        }
    }
}

struct SmbcImage: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        let paddingSize: CGFloat? = sizeClass == .compact ? nil : 100.0
        Image(.smbc)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
            .padding(.horizontal, paddingSize)
    }
}

// MARK: Background gradient

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

#Preview {
    @State var viewState: ViewState = .init()
    return ContentView(viewState: $viewState)
        .environment(ProgramState())
}
