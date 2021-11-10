 //
//  Downloader.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
//  Copyright © 2019, 2021 Marco S Hyman. All rights reserved.
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

/// Ecapsulate a generic version of the code to download the various bits of data that make up
/// the program model.
struct Downloader<T: Decodable> {

    /// Fetch data from url and store in a local cache.  Decode the data as JSON.
    ///
    /// - Parameter name:   The name of the locally cached file
    /// - Parameter url:    The url of a file to download
    /// - Parameter type:   The type of structure that should match the downloaded data
    /// - Returns:          Decoded downloaded data
    ///
    static func fetch(
        name: String,
        url: URL,
        type: T.Type
    ) async throws -> T {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let (data, _) = try await session.data(from: url)
        let decodedData = try decoder.decode(type, from: data)
        let cache = Cache(name: name, type: type)
        let cacheUrl = cache.fileUrl()
        try data.write(to: cacheUrl)
        return decodedData
    }
}
