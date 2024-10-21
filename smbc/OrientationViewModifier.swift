//
//  OrientationViewModifier.swift
//  smbc
//
//  Created by Marco S Hyman on 7/12/23.
//  Code copied from Hacking With Swift
//

import SwiftUI

// View modifier to track rotation and call action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
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
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
