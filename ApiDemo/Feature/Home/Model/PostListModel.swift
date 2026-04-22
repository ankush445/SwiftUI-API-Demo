//
//  Post.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import Foundation


struct LikeModel: Codable {
    let success: Bool
    let liked: Bool
}
// Create Post Model
struct PostModel: Codable {
    let success: Bool
    let message: String?

}

// POST Like Model 
struct PostListResponse: Codable {
    let success: Bool
    let message: String?
    let posts: [Post]
    let nextCursor: String?
    let hasMore: Bool
}

struct Post: Identifiable, Codable {
    let id: String
    let title: String
    let content: String?
    let createdAt: String
    let user: User
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case content
        case createdAt
        case user
        case likeCount
        case commentCount
        case isLiked
    }
}
