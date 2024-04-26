//
//  Downloader.swift
//  smbc
//
//  Created by Marco S Hyman on 7/27/19.
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
    static func fetch(name: String, url: URL, type: T.Type) async throws -> T {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: configuration,
                                 delegate: nil, delegateQueue: nil)
        let decoder = JSONDecoder()
        let (data, _) = try await session.data(from: url)
        let decodedData = try decoder.decode(type, from: data)
        // update the cache in the background
        Task(priority: .background) {
            let cache = Cache(name: name, type: type)
            let cacheUrl = cache.fileUrl()
            try data.write(to: cacheUrl)
        }
        return decodedData
    }
}
