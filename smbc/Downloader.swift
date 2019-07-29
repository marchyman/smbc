 //
//  Downloader.swift
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

let serverName = "https://smbc.snafu.org/"
 
struct Downloader<T: Decodable> {
    var publisher: AnyPublisher<T, Error>

    enum NetworkError: Error {
        case badResponse
    }
    
    /// Initialize the structure's publisher member
    /// - Parameter url: The url of a file to download
    /// - Parameter type: The type of structure that should match the downloaded data
    /// - Parameter cache: A url of a cache file.  If the URL is non-nil downloaded data will be
    ///     cached at the given location.
    ///
    init(url: URL, type: T.Type, cache: URL?) {
        print("Download \(url)")
        publisher = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap {
                (data: Data, response: URLResponse) -> Data in
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        throw NetworkError.badResponse
                }
                if let cache = cache {
                    try data.write(to: cache)
                }
                return data
            }
            .decode(type: type, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
