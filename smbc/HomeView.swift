//
//  HomeView.swift
//  smbc
//
//  Created by Marco S Hyman on 4/25/24.
//  Copyright © 2024 Marco S Hyman. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Bindable var viewState = ViewState.shared

    @State private var runRefreshTask = false
    @State private var noMoreRides = false
    @State private var showLog = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("""
                   [Sunday Morning Breakfast Club\nBreakfast and beyond \
                   since 1949](https://smbc.snafu.org/)
                   """)
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
            .frame(maxWidth: .infinity)
            .background(backgroundGradient(colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("SMBC")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showLog = true
                    } label: {
                        // the label is hidden, but still can be tapped
                        Text("Log")
                            .padding(.horizontal)
                            .opacity(0.0)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack { SmbcHelp(); SmbcInfo() }
                }
            }
            .sheet(isPresented: $noMoreRides) {
                NoMoreRideView()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showLog) {
                LogView()
            }
            .task(id: runRefreshTask) {
                // load current schedule if necessary.
                await viewState.refresh(state)
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(ProgramState())
}
