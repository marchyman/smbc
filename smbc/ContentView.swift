//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
//

import SwiftUI

// MARK: - Initial Content

@MainActor
struct ContentView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Bindable var viewState = ViewState.shared

    var body: some View {
        TabView(selection: $viewState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(TabItems.home)

            RestaurantListView()
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }
                .tag(TabItems.restaurants)

            RideListView()
                .tabItem {
                    Label("Rides", systemImage: "map")
                }
                .tag(TabItems.rides)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    return ContentView()
        .environment(ProgramState())
}
