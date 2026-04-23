//
//  Font+Extension.swift
//  DictateNow
//
//  Created by ios-22 on 19/02/25.
//

import Foundation
import SwiftUI

enum FontWeight {
    case regular
    case medium
    case bold
    case semiBold
}

extension Font {
    static let customFont: (FontWeight, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .regular:
            Font.custom("PlusJakartaSans-Regular", size: size)
        case .medium:
            Font.custom("PlusJakartaSans-Medium", size: size)
        case .semiBold:
            Font.custom("PlusJakartaSans-SemiBold", size: size)
        case .bold:
            Font.custom("PlusJakartaSans-Bold", size: size)
        }
    }
}

extension Text {
    func customFont(_ fontWeight: FontWeight? = .regular, _ size: CGFloat? = nil) -> Text {
        return self.font(.customFont(fontWeight ?? .regular, size ?? 16))
    }
}

extension Button {
    func customFont(_ fontWeight: FontWeight? = .regular, _ size: CGFloat? = nil) -> some View {
        self.font(.customFont(fontWeight ?? .regular, size ?? 16))
    }
}

extension TextField {
    func customFont(_ fontWeight: FontWeight = .regular, _ size: CGFloat = 16) -> some View {
        self.font(.customFont(fontWeight, size))
    }
}

extension HStack {
    func customFont(_ fontWeight: FontWeight? = .regular, _ size: CGFloat? = nil) -> some View {
        self.modifier(CustomFontModifier(fontWeight: fontWeight ?? .regular, size: size ?? 16))
    }
}

// Helper modifier for custom font
struct CustomFontModifier: ViewModifier {
    var fontWeight: FontWeight
    var size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.customFont(fontWeight, size))
    }
}


extension View {
    func customFont(_ fontWeight: FontWeight = .regular, _ size: CGFloat = 16) -> some View {
        self.modifier(CustomFontModifier(fontWeight: fontWeight, size: size))
    }
}


extension Image {
    func customFont(_ fontWeight: FontWeight = .regular, _ size: CGFloat = 16) -> some View {
        self.font(.customFont(fontWeight, size))
    }
}
