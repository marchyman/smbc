//
//  NoMoreRideView.swift
//  smbc
//
//  Created by Marco S Hyman on 1/22/23.
//  Copyright © 2023 Marco S Hyman. All rights reserved.
//

import SwiftUI

struct NoMoreRideView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Dismiss") {
                    dismiss()
                }
            }
            .padding()

            Text("""
                There are no more rides scheduled for the current year. \
                Please load the schedule for the next year. This normally \
                happens automatically some time during the last week of \
                the year.
                """)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NoMoreRideView()
}
