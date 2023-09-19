//
//  smbc.swift
//  smbc
//
//  Created by Marco S Hyman on 1/22/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import SwiftUI

@main
struct SmbcApp: App {
    @State var programState = ProgramState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(programState)
        }
    }
}
