//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
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
    public static var smbc: SmbcButtonStyle.Member {
        StaticMember<SmbcButtonStyle>(SmbcButtonStyle())
    }
}

struct ContentView : View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Sunday Morning Breakfast Club\nBreakfast and beyond since 1949")
                    .lineLimit(2)
                    .padding(.top, 50)
                Text("")
//                Spacer()      // adding spacer shrinks the following image
                Image("smbc")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .padding()
//                Spacer()      // adding spacer shrinks the above image
                HStack {
                    Spacer()
                    NavigationButton(destination: RestaurantView()) {
                        Text("Restaurants").font(.title)
                    }.buttonStyle(.smbc)
                    Spacer()
                    NavigationButton(destination: RideView()) {
                        Text("Rides").font(.title)
                    }.buttonStyle(.smbc)
                    Spacer()
                }.padding(.bottom, 50)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
             .background(LinearGradient(gradient: Gradient(colors: [.white, .gray, .white]), startPoint: .top, endPoint: .bottom), cornerRadius: 0)
             .navigationBarTitle(Text("SMBC"))
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
