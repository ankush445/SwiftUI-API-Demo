//
//  AppStrings.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//
import Foundation
enum AppStrings {
    
    // MARK: - Auth Titles
    static let appName = localized("auth.app_name")
    static let loginSubtitle = localized("auth.login_subtitle")
    static let signupSubtitle = localized("auth.signup_subtitle")
    
    // MARK: - Fields
    static let fullName = localized("auth.full_name")
    static let email = localized("auth.email")
    static let password = localized("auth.password")
    static let username = localized("auth.username")
    static let usernameInvalidFormat = localized("auth.username_invalid_format")
    static let checking = localized("auth.checking")
    static let usernameAvailable = localized("auth.username_available")
    static let usernameTaken = localized("auth.username_taken")
    static let resetPassword = localized("auth.reset_password")
    static let resetPasswordSubtitle = localized("auth.reset_password_subtitle")
    static let newPassword = localized("auth.new_password")
    static let confirmPassword = localized("auth.confirm_password")
    static let updatePassword = localized("auth.update_password")
    static let invalidName = localized("auth.invalid_name")
    static let invalidEmail = localized("auth.invalid_email")
    static let invalidPassword = localized("auth.invalid_password")
    static let passwordNotMatch = localized("auth.password_not_match")
    static let somethingWentWrong = localized("auth.something_wrong")
    
    // MARK: - Buttons
    static let login = localized("auth.login")
    static let signUp = localized("auth.signup")
    
    // MARK: - Other
    static let forgotPassword = localized("auth.forgot_password")
    static let orContinue = localized("auth.or_continue")
    
    // MARK: - Toggle
    static let noAccount = localized("auth.no_account")
    static let alreadyAccount = localized("auth.already_account")
    
    // MARK: - Social
    static let google = localized("auth.google")
    static let facebook = localized("auth.facebook")
}

// 🔑 Localization Helper
private func localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
