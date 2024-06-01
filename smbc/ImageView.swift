//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import SwiftUI

struct ImageView: View {
    let imageName: String

    var body: some View {
        AsyncImage(url: URL(string: serverName + imageName)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(7)
                .padding()
        } placeholder: {
            ProgressView()
        }
    }
}

#Preview {
    NavigationStack {
        ImageView(imageName: "https://smbc.snafu.org/riders/2024/0526/p-00983.jpg")
    }
}
