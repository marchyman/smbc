//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct ImageZoomView: View {
    @State private var scale = 1.0
    @State private var zoom = 0.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    let imageName: String

    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: imageName)) { phase  in
                switch phase {
                case .empty:
                    ContentUnavailableView(
                        "Image Loading...",
                        systemImage: "circle.hexagongrid.fill"
                    )
                        .symbolEffect(.pulse, options: .repeating)
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(7)
                        .offset(offset)
                        .padding()
                        .scaleEffect(scale + zoom)
                        .onTapGesture(count: 2) {
                            scale = 1
                            offset = .zero
                        }
                        .gesture(magnification.simultaneously(with: drag))
                default:
                        Image(systemName: "hand.thumbsdown")
                        Text("Failed to load image")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var magnification: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .onChanged { value in
                zoom = value.magnification - 1
            }
            .onEnded { _ in
                scale += zoom
                zoom = 0
            }
    }

    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                var newOffset: CGSize = .zero
                newOffset.width = value.translation.width + lastOffset.width
                newOffset.height = value.translation.height + lastOffset.height
                offset = newOffset
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}

#Preview {
    NavigationStack {
        ImageZoomView(imageName: "riders/2024/0526/p-00983.jpg")
    }
}
