//
//  HomeView.swift
//  smbc
//
//  Created by Marco S Hyman on 4/25/24.
//  Copyright © 2024 Marco S Hyman. All rights reserved.
//

import SwiftUI

@MainActor
struct HomeView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Bindable var viewState = ViewState.shared

    @State private var noMoreRides = false
    @State private var runRefreshTask = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("[Sunday Morning Breakfast Club\nBreakfast and beyond since 1949](https://smbc.snafu.org/)")
                    .font(.headline)
                    .lineLimit(2)
                    .padding()
                Spacer()
                SmbcImage()
                    .onTapGesture {
                        if let nextRide = state.rideModel.nextRide() {
                            viewState.nextRide = nextRide
                            viewState.selectedTab = .rides
                        } else {
                            noMoreRides.toggle()
                        }
                    }
                    .onLongPressGesture {
                        viewState.refreshPresented = true
                        viewState.forceRefresh = true
                        runRefreshTask.toggle()
                    }
                Spacer()
            }
            .background(backgroundGradient(colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("SMBC")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack { SmbcHelp(); SmbcInfo() }
                }
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
            .sheet(isPresented: $noMoreRides) {
                NoMoreRideView()
                    .presentationDetents([.medium])
            }
            .task(id: runRefreshTask) {
                await viewState.refresh(state)
            }
        }
    }

}

#Preview {
    HomeView()
}
