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
    let nextCursor: String?
    let hasMore: Bool
}

struct Comment: Identifiable, Codable {
    
    let id: String
    let text: String
    let user: CommentUser
    let postId: String
    let createdAt: Date
    let updatedAt: Date
    let parentCommentId: String?
    let likesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case user = "userId" // ✅ IMPORTANT mapping
        case postId
        case createdAt
        case updatedAt
        case parentCommentId
        case likesCount
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
