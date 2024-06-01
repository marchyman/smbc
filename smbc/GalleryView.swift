//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import SwiftUI

struct GalleryView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var path: NavigationPath = .init()

    let testName = [
        "https://smbc.snafu.org/riders/2024/0526/p-00983.jpg",
        "https://smbc.snafu.org/riders/2024/0526/p-00986.jpg",
        "https://smbc.snafu.org/riders/2024/0526/p-00994.jpg",
        "https://smbc.snafu.org/riders/2024/0526/p-00998.jpg",
        "https://smbc.snafu.org/riders/2024/0526/p-01001.jpg"
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack {
                    ForEach(testName, id: \.self) { name in
                        NavigationLink(destination: ImageZoomView(imageName: name)) {
                            ImageView(imageName: name)
                        }
                    }
                }
            }
            .background(backgroundGradient(colorScheme))
            .navigationTitle("Riders Gallery Images")
        }
    }
}

#Preview {
        GalleryView()
            .environment(ProgramState())
}
