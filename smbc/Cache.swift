//
//  Cache.swift
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

struct Cache<T: Decodable> {
    var name: String
    var type: T.Type
    
    /// Return a URL for the named cache file
    ///
    /// Cached files live in folder in the users .cachesDirectory.  The folder name is the
    /// applicatoin bundle ID.  The folder will be created if it does not exist.  If the cached file
    /// does not exist primeCache() is called to prime the cache with data stored in the bundle.
    ///
    func fileUrl() -> URL {
        let fileManager = FileManager.default
        do {
            let cachesDir = try fileManager.url(for: .cachesDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true)
            let cacheFolderName = "\(Bundle.main.bundleIdentifier!)/"
            let cacheFolder = cachesDir.appendingPathComponent(cacheFolderName)
            try fileManager.createDirectory(at: cacheFolder,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            let cacheUrl = cacheFolder.appendingPathComponent(name)
            if !fileManager.fileExists(atPath: cacheUrl.path) {
                primeCache(at: cacheUrl)
            }
            return cacheUrl
        } catch {
            fatalError("Cannot create cache folder for: \(name)")
        }
    }
    
    /// Return cached data for this name/type
    ///
    func cachedData<T: Decodable>() -> T {
        let url = fileUrl()
        if let cachedData = try? Data(contentsOf: url) {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(type, from: cachedData)
                return decoded as! T
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
            fatalError("JSON Decoding Error for \(name)")
        } else {
            fatalError("Cannot read cached data for \(name)")
        }
    }
    
    /// Prime the cache from data stored in the bundle
    /// - Parameter cacheUrl: URL of named file in cache folder
    ///
    func primeCache(at cacheUrl: URL) {
        do {
            // break the name into base name and extension
            guard let dotIndex = name.lastIndex(of: ".") else {
                fatalError("malformed resource name: \(name)")
            }
            let resource = String(name.prefix(upTo:dotIndex))
            let extRange = name.index(after: dotIndex)..<name.endIndex
            let ext = String(name[extRange])

            // URL to data in bundle
            let bundleUrl = Bundle.main.url(forResource: resource,
                                            withExtension: ext)!
            try FileManager.default.copyItem(at: bundleUrl, to: cacheUrl)
        } catch {
            fatalError("Cannot prime cache: \(name)")
        }
    }
}
