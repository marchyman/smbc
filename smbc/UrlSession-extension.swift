//
//  UrlSession-extension.swift
//  smbc
//
//  Created by Marco S Hyman on 11/8/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
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

//@available(iOS, deprecated: 15.0, message: "Use the built-in API instead")
//extension URLSession {
//    func data(from url: URL) async throws -> (Data, URLResponse) {
//        try await withCheckedThrowingContinuation { continuation in
//            let task = self.dataTask(with: url) { data, response, error in
//                guard let data = data,
//                      let httpResponse = response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200
//                else {
//                    let error = error ?? URLError(.badServerResponse)
//                    return continuation.resume(throwing: error)
//                }
//
//                continuation.resume(returning: (data, response!))
//            }
//
//            task.resume()
//        }
//    }
//}
