//
//  RestaurantDetailView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
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

struct RestaurantDetailView : View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack {
            Text(restaurant.name).font(.title)
            Text(restaurant.address)
            Text(restaurant.city)
            Text(restaurant.phone)
            Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
             .background(LinearGradient(gradient: Gradient(colors: [.white, .gray, .white]), startPoint: .top, endPoint: .bottom), cornerRadius: 0)
    }
}

#if DEBUG
struct RestaurantDetailView_Previews : PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant(id: "test",
                                                    name: "Test Restaurant",
                                                    address: "123 Main Street",
                                                    city: "Some City",
                                                    phone: "(123) 456-7890",
                                                    status: "CLOSED"))
    }
}
#endif