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

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack {
                    ForEach(state.galleryModel.imageNames, id: \.self) { name in
                        NavigationLink(destination: ImageZoomView(imageName: name)) {
                            ImageView(imageName: name)
                        }
                    }
                }
            }
            .refreshable {
                try? await state.galleryModel.fetch()
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
