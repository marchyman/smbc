//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI

// View modifier to set the background

public struct SMBCBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    public func body(content: Content) -> some View {
        content
            .background(gradientBackground(colorScheme).opacity(0.50))
    }

    func gradientBackground(_ colorScheme: ColorScheme) -> LinearGradient {
        let color: Color = if colorScheme == .light { .white } else { .black }
        return LinearGradient(
            gradient: Gradient(colors: [color, .gray, color]),
            startPoint: .top,
            endPoint: .bottom)
    }
}

extension View {
    public func smbcBackground() -> some View {
        self.modifier(SMBCBackground())
    }
}
