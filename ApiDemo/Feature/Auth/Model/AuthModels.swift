//
//  LoginRequest.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import Foundation

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
    let email: String
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"   // ✅ mapping fix
        case name
        case email
        case createdAt
        case updatedAt
    }
}
