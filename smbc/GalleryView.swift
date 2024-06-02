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
                    ForEach(state.galleryModel.names, id: \.self) { name in
                        if name.isJpg() {
                            NavigationLink(destination: ImageZoomView(imageName: name)) {
                                ImageView(imageName: name)
                                    .frame(height: 300)
                            }
                        } else {
                            MarkdownView(name: name)
                                .frame(height: 300)
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
