//
//  FancyToastView.swift
//  FancyToastKit
//
//  Created by ios-22 on 18/03/26.
//

import SwiftUI

public struct FancyToastView: ViewModifier {
    @Binding var toast: FancyToast?
    @State private var workItem: DispatchWorkItem?
    
    public init(toast: Binding<FancyToast?>) {
        self._toast = toast
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .overlay(
                    ZStack {
                        mainToastView()
                            .offset(y: 10)
                    }
                        .animation(.easeInOut(duration: 0.3), value: toast)
                )
                .onChange(of: toast) { _, _ in
                    showToast()
                }
        } else {
            content
                .overlay(
                    ZStack {
                        mainToastView()
                            .offset(y: 10)
                    }
                        .animation(.easeInOut(duration: 0.3), value: toast)
                )
                .onChange(of: toast) { _ in
                    showToast()
                }
        }
    }
    
    @ViewBuilder
    private func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                FancyToastKit(
                    type: toast.type,
                    title: toast.title,
                    message: toast.message
                ) {
                    dismissToast()
                }
                
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissToast()
            }
            
            workItem = task
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + toast.duration,
                execute: task
            )
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}
