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
                        viewState.runRefreshTask.toggle()
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
            .sheet(isPresented: $noMoreRides) {
                NoMoreRideView()
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    HomeView()
}
