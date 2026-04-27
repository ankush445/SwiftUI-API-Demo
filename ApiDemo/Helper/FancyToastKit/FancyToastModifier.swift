//
//  FancyToastModifier.swift
//  fancyToastKit
//
//  Created by ios-22 on 18/03/26.
//

import SwiftUI

public extension View {
    func toastView(toast: Binding<FancyToast?>) -> some View {
        self.modifier(FancyToastView(toast: toast))
    }
}
