//
//  State.swift
//  smbc
//
//  Created by Marco S Hyman on 7/24/19.
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


struct ScheduleYear: Codable, Equatable {
    var year: String
}

/// A class to hold program state

class ProgramState: Codable {
    var scheduleYears: [ScheduleYear]   // data available for these years
    var cachedIndex: Int                // index into scheduleYears for cached year
    var selectedIndex: Int              // year selection index
    var refreshTime: Date               // when to refresh the cache

    /// load state data from local storage if it exists
    /// - Returns: program state
    ///
    /// If state data does not exist or could not be decoded create and save a new instance
    ///
    static func load() -> ProgramState {
        let state: ProgramState
        do {
            // read and decode state from the documents file if it exists
            let data = try Data(contentsOf: ProgramState.stateFileUrl())
            let decoder = JSONDecoder()
            state = try decoder.decode(ProgramState.self, from: data)
        } catch {
            // Create and store a newly initialized State
            state = ProgramState()
            ProgramState.store(state)
        }
        return state
    }

    /// Store the given ProgramState in the users documents folder
    /// - Parameter state: data to store in local storage
    ///
    static func store(_ state: ProgramState) {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(state) else {
            fatalError("Cannot encode state file")
        }
        do {
            try encoded.write(to: ProgramState.stateFileUrl())
        } catch {
            fatalError("Cannot write state file")
        }
    }
    
    /// Return the URL for the local program state file
    /// The state file lives in the application support folder for this app.  The folder will be created if
    /// if it doesn't exist.
    ///
    static func stateFileUrl() throws -> URL {
        let programStateFolderName = "\(Bundle.main.bundleIdentifier!)/"
        let programStateFileName = "SMBCState.json"

        let fileManager = FileManager.default
        let supportFolder = try fileManager.url(for: .applicationSupportDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
        let stateFolder = supportFolder.appendingPathComponent(programStateFolderName)
        try fileManager.createDirectory(at: stateFolder,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        let stateFile = stateFolder.appendingPathComponent(programStateFileName)
        return stateFile
    }

    /// Create an instance of ProgramState based upon the current time
    ///
    init() {
        // default data stored in the app bundle is for this year
        let bundledDataYear = "2019"
        scheduleYears = [ScheduleYear(year: bundledDataYear)]
        cachedIndex = 0
        refreshTime = Date()
        selectedIndex = 0
    }
    
    /// Find the index into scheduleYears for the entry that matches the given year
    /// - Parameter year: The year to find
    /// - Returns: The index matching the given year
    ///
    /// The year is assumed to exist in the array.  If not the program aborts.
    ///
    func findYearIndex(year: String) -> Int {
        guard let ix = scheduleYears.firstIndex(of: ScheduleYear(year: year)) else {
            fatalError("Cannot find index for requested year")
        }
        return ix
    }
}
