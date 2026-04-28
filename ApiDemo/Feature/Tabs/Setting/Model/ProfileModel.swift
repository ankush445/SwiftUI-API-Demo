//
//  ProfileModel.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//
import Foundation
struct ProfileResponseDTO: Codable {
    let success: Bool
    let message: String?
    let user: User
    let posts: [Post]
    let nextCursor: String?
    let hasMore: Bool
}

