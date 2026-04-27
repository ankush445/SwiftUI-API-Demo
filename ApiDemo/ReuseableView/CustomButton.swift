//
//  CustomButton.swift
//  DictateNow
//
//  Created by ios-22 on 19/02/25.
//


import SwiftUI

struct CustomButton: View {
    var title: String
    var backgroundColor: Color = .buttonBackground // Default Red Color
    var cornerRadius:CGFloat = 10
    var action: () -> Void
    
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .customFont(.medium, 16)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
        .padding(.horizontal)
    }
}
