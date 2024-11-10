//
//  RefreshMessages.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import SwiftUI

struct ScheduleReloadView: View {
    var body: some View {
        Text(
            """
            Up to date Trip, Restaurant, and Schedule data is being retrieved \
            from smbc.snafu.org

            It may take a few seconds for the updated data to be received and processed.
            """)
    }
}

struct ReloadErrorView: View {
    let description: String

    var body: some View {
        Text(
            """
            \(description)

            There may be internet and/or server issues. As a result the \
            ride schedule data on this device may be out of date.

            Please try to refresh the data again once the issue has been \
            resolved. You can also obtain the current schedule from the \
            [SMBC home page](https://smbc.snafu.org).
            """)
    }
}

#Preview {
    ScheduleReloadView()
}

#Preview {
    ReloadErrorView(description: "Error description goes here")
}
