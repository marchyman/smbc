//
// Copyright 2023 Marco S Hyman
// https://www.snafu.org/

//  Code copied from Hacking With Swift

import SwiftUI

// View modifier to track rotation and call action

public struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    public func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(
                NotificationCenter
                    .default
                    .publisher(for: UIDevice.orientationDidChangeNotification)
            ) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    public func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
