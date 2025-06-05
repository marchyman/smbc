//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct ImageView: View {
    let imageName: String

    var body: some View {
        VStack(spacing: 2) {
            Text(imageName)
                .font(.headline)
                .truncationMode(.tail)
                .padding([.leading, .trailing, .bottom])
            Spacer()
            AsyncImage(url: URL(string: imageName)) { phase  in
                switch phase {
                case .empty:
                        Image(systemName: "circle.hexagongrid.fill")
                            .symbolEffect(.pulse, options: .repeating)
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(7)
                        .padding(.horizontal)
                default:
                        Spacer()
                        Image(systemName: "hand.thumbsdown")
                        Text("Failed to load image")
                        Spacer()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ImageView(imageName: "riders/2024/0526/p-00983.jpg")
            .frame(height: 300)
    }
}
