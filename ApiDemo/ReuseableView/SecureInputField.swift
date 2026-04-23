//
//  SecureInputField.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//
import SwiftUI

struct SecureInputField: View {
    
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    @State private var showPassword = false
    
    var body: some View {
        HStack {
            
            Image(systemName: icon)
                .foregroundColor(Color.textFieldIconBackground)
            
            Group {
                if showPassword {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .customFont(.regular, 16)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
