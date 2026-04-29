//
//  EditProfileModel.swift
//  ApiDemo
//
//  Created by ios-22 on 29/04/26.
//

import Foundation

struct EditProfileRequest: Codable {
    let name: String
    let username: String
    let bio: String
    let website: String?
    let profileImage: String?
}

struct EditProfileResponse: Codable {
    let success: Bool
    let message: String?
    let user: User
}

struct SettingsOption {
    let id: String
    let title: String
    let icon: String
    let color: String
}
