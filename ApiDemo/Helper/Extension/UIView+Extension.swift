//
//  UIView+Extension.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
#endif
// MARK: - Keyboard Dismiss Helper
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//
//// Add a helper to get device-specific dimensions
//extension View {
//    func adaptiveFrame(for device: UIUserInterfaceIdiom) -> some View {
//        self.modifier(AdaptiveFrameModifier(device: device))
//    }
//}
//
//struct AdaptiveFrameModifier: ViewModifier {
//    let device: UIUserInterfaceIdiom
//
//    func body(content: Content) -> some View {
//        content
//            .frame(height: device == .pad ? 200 : 100)
//    }
//}
//
//// MARK: - Accessibility Modifer
//extension View {
//    func accessibilitySpeak(label: String, hint: String? = nil, traits: AccessibilityTraits = .isButton) -> some View {
//        self
//            .accessibilityElement()
//            .accessibilityLabel(Text(label))
//            .accessibilityHint(Text(hint ?? ""))
//            .accessibilityAddTraits(traits)
//    }
//}
//
//func announce(_ message: String, delay: Double = 0.5) {
//    if UIAccessibility.isVoiceOverRunning {
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            UIAccessibility.post(notification: .announcement, argument: message)
//        }
//    }
//}
