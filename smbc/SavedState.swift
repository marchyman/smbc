//
//  SavedState.swift
//  smbc
//
//  Created by Marco S Hyman on 11/10/21.
//  Copyright © 2021 Marco S Hyman. All rights reserved.
//
//  Created by Marco S Hyman on 7/24/19.
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

/// The schedule for a year is stored in the app bundle to initialize needed state before updated
/// data is downloaded from the SMBC server.  This is the year of the stored schedule
///
fileprivate let bundleScheduleYear = 2021

/// Data to create the url for local saved state
///
fileprivate let programStateFolderName = "\(Bundle.main.bundleIdentifier!)/"
fileprivate let programStateFileName = "SMBCState.json"

/// Saved application state
///
struct SavedState: Codable {
    var year: Int                   // current schedule year
    var refreshTime: Date           // when to refresh the cache
    var mapTypeIndex: Int           // desired map display type

    init() {
        year = bundleScheduleYear
        refreshTime = Date()
        mapTypeIndex = 0
    }

    /// load state data from local storage if it exists
    /// - Returns: saved application state
    ///
    /// If state data does not exist or could not be decoded create and save a new instance
    ///
    static func load() -> SavedState {
        let state: SavedState
        do {
            // read and decode state from the documents file if it exists
            let data = try Data(contentsOf: SavedState.stateFileUrl())
            let decoder = JSONDecoder()
            state = try decoder.decode(SavedState.self, from: data)
        } catch {
            // Create and store a newly initialized State
            state = SavedState()
            SavedState.store(state)
        }
        return state
    }

    /// Store the given ProgramState in the users documents folder
    /// - Parameter state: data to store in local storage
    ///
    static func store(_ state: SavedState) {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(state) else {
            fatalError("Cannot encode state file")
        }
        do {
            try encoded.write(to: SavedState.stateFileUrl())
        } catch {
            fatalError("Cannot write state file")
        }

    }

    /// Return the URL for the local program state file
    /// The state file lives in the application support folder for this app.  The folder will be created if
    /// if it doesn't exist.
    ///
    static func stateFileUrl() throws -> URL {
        let fileManager = FileManager.default
        let supportFolderUrl = try fileManager
            .url(for: .applicationSupportDirectory,
                 in: .userDomainMask,
                 appropriateFor: nil,
                 create: false)
        let stateFolderUrl = supportFolderUrl
            .appendingPathComponent(programStateFolderName)
        try fileManager
            .createDirectory(at: stateFolderUrl,
                             withIntermediateDirectories: true,
                             attributes: nil)
        let stateFileUrl = stateFolderUrl
            .appendingPathComponent(programStateFileName)
        return stateFileUrl
    }

}
