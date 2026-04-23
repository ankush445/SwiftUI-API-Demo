
//
//  Untitled.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//
import SwiftUI

// Input Field
func inputField(icon: String, placeholder: String, text: Binding<String>) -> some View {
    HStack {
        Image(systemName: icon)
            .foregroundColor(Color.textFieldIconBackground)
        
        TextField(placeholder, text: text)
            .customFont(.regular, 16)
            .textInputAutocapitalization(.never)
    }
    .padding()
    .background(Color.textFieldBackground)
    .cornerRadius(12)
}

// Secure Field
func secureField(icon: String, placeholder: String, text: Binding<String>) -> some View {
    HStack {
        Image(systemName: icon)
            .foregroundColor(Color.textFieldIconBackground)

        SecureField(placeholder, text: text)
            .customFont(.regular, 16)

    }
    .padding()
    .background(Color.gray.opacity(0.1))
    .cornerRadius(12)
}

// Social Button
func socialButton(title: String, icon: String) -> some View {
    HStack {
        Image(systemName: icon)
        Text(title)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.white)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.3))
    )
    .cornerRadius(12)
}
