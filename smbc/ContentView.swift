//
//  ContentView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/22/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        VStack {
            Button(action: { } ) {
                Text("Breakfast rides")
                    .padding()
            }
            Button(action: {} ) {
                Text("Other rides")
                    .padding()
            }
            Button(action: {} ) {
                Text("Restaurants")
                    .padding()
            }
            // self.backgroundImage(geometry.size.width, geometry.size.height)
        }
    }
    
    func backgroundImage(width: CGFloat, height: CGFloat) -> Image {
        let name = "l\(Int(width))x\(Int(height))"
        print(name)
        return Image(systemName: "slowmo")
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
