//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import SwiftUI

struct ImageView: View {
    let imageName: String

    var body: some View {
        VStack(spacing: 2) {
            Text(imageName)
                .font(.headline)
                .padding(.bottom)
            AsyncImage(url: URL(string: serverName + imageName)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(7)
                    .padding(.horizontal)
            } placeholder: {
                Spacer()
                Image(systemName: "circle.hexagongrid.fill")
                    .symbolEffect(.pulse, options: .repeating)
                Spacer()
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
