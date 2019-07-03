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
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    var body: some View {
        NavigationView {
            VStack {
                Text("""
                     Sunday Morning Breakfast Club
                     Breakfast and beyond since 1949
                     """)
                    .font(.body)
                    .lineLimit(2)
                    .padding()
                Image("smbc")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .padding(.leading)
                    .padding(.trailing)
                HStack {
                    Spacer()
                    NavigationLink(destination: RestaurantView()) {
                        Text("Restaurants").font(.title)
                    }.buttonStyle(.smbc)
                    Spacer()
                    NavigationLink(destination: RideView()) {
                        Text("Rides").font(.title)
                    }.buttonStyle(.smbc)
                    Spacer()
                }.padding()
             }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
              .background(LinearGradient(gradient: backgroundGradient(), startPoint: .top, endPoint: .bottom), cornerRadius: 0)
              .navigationBarTitle(Text("SMBC"))
        }
    }
    
    private
    func backgroundGradient() -> Gradient {
        let color: Color
        switch colorScheme {
        case .light:
            color = .white
        case .dark:
            color = .black
        @unknown default:
            fatalError("Unknown ColorScheme")
        }
        return Gradient(colors: [color, .gray, color])
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
