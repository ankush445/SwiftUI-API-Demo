//
//  LoginRequest.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import Foundation

struct UserNameCheck: Codable {
    let success: Bool
    let available: Bool?
    let message: String?
}

struct ResetPassword: Codable {
    let success: Bool
    let resetToken: String?
    let message: String?
}

struct ApiResponse<T: Codable>: Codable {
    let success: Bool
    let message: String? // ✅ optional
    let data: T
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let username: String
    let email: String?
    let followers: Int?
    let following: Int?
    let postCount: Int?
    let followStatus: String?
    let bio: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"   // ✅ mapping fix
        case name
        case username
        case email
        case followers
        case following
        case postCount
        case followStatus
        case bio
        case createdAt
        case updatedAt
    }
}

extension User {
    func toDomain() -> ProfileModel {
        return ProfileModel(
            id: id,
            name: name,
            email: email ?? "",
            username: username,
            followers: followers ?? 0,
            following: following ?? 0,
            postCount: postCount ?? 0,
            followStatus: FollowStatus(rawValue: followStatus ?? "") ?? .none
        )
    }
}

struct ProfileModel {
    let id: String
    let name: String
    let email: String
    let username: String
    let followers: Int
    let following: Int
    let postCount: Int
    var followStatus: FollowStatus
}
