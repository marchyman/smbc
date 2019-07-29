//
//  TripModel.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
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

import Foundation
import Combine
import SwiftUI

class TripModel: BindableObject {
    let willChange = PassthroughSubject<Void, Never>()

    var trips = [String : String]() {
        willSet {
            willChange.send()
        }
    }

    init(refresh: Bool) {
        let name = "trips.json"
        let cache = Cache(name: name, type: [String : String].self)
        if refresh {
            let url = URL(string: serverName + "schedule/" + name)!
            let cacheUrl = try? cache.fileUrl()
            let downloader = Downloader(url: url, type: [String : String].self, cache: cacheUrl)
            downloader.publisher
                .catch {
                    error -> Just<[String : String]> in
                    print("Error: \(error)")
                    return Just(cache.cachedData())
                }
                .assign(to: \.trips, on: self)
        } else {
            trips = cache.cachedData()
        }
    }
}

