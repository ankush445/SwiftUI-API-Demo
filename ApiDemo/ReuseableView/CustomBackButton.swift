//
//  CustomBackButton.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//

import SwiftUI
struct CustomBackButton: View {
    
    let title: String?
    var action: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(spacing: 8) {
            
            Button {
                if let action = action {
                    action()
                } else {
                    dismiss()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    
                    if let title = title {
                        Text(title)
                            .customFont(.semiBold, 16)
                    }
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}
extension View {
    
    func customBackButton(
        title: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackButton(title: title, action: action)
                }
            }
    }
}
