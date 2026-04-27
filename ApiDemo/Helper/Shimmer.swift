//
//  Shimmer.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//
import SwiftUI
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.3)
                        ]),
                        startPoint: .leading,   // 👈 LEFT
                        endPoint: .trailing     // 👈 RIGHT
                    )
                    .frame(width: geo.size.width * 1.5) // 👈 wider for smooth flow
                    .offset(x: phase * geo.size.width)
                }
            )
            .mask(content)
            .onAppear {
                phase = -1
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(Shimmer())
    }
}
