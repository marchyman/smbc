//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Gallery
import SwiftUI
import Schedule
import UDF

@main
struct SmbcApp: App {
    @State private var galleryStore = Store(initialState: GalleryState(),
                                            reduce: GalleryReducer(),
                                            name: "Gallery Store")
    @State private var scheduleStore = Store(initialState: ScheduleState(),
                                            reduce: ScheduleReducer(),
                                            name: "Schedule Store")
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(galleryStore)
                .environment(scheduleStore)
        }
    }
}
