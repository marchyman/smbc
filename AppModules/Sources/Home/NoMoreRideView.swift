//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct NoMoreRideView: View {
    var body: some View {
        VStack {
            Text(
                """
                There are no more rides scheduled for the current year. \
                Please load the schedule for the next year. This normally \
                happens automatically some time during the last week of \
                the year.
                """)
        }
        .padding()
    }
}

#Preview {
    NoMoreRideView()
}
