//
//  CommentListResponse.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//

import Foundation
struct CommentListResponse: Codable {
    let success: Bool
    let data: [Comment]
}

struct Comment: Identifiable, Codable {
    
    let id: String
    let text: String
    let user: CommentUser
    let postId: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case user = "userId" // ✅ IMPORTANT mapping
        case postId
        case createdAt
        case updatedAt
    }
}

struct CommentUser: Codable {
    let id: String
    let name: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
    }
}
