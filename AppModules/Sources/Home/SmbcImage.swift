//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

struct SmbcImage: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        let paddingSize: CGFloat? = sizeClass == .compact ? nil : 100.0
        Image(.smbc)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
            .padding(.horizontal, paddingSize)
    }
}

#Preview {
    SmbcImage()
}
