//
//  Validator.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//
import Foundation


func isValidEmail(email: String) -> Bool {
    let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex)
        .evaluate(with: email)
}
func isValidName(name: String) -> Bool {
    return name.trimmingCharacters(in: .whitespaces).count >= 2
}

func isValidPassword(password: String) -> Bool {
    // Minimum 6 characters (you can upgrade later)
    return password.count >= 6
}
