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
    let user: User
    var likeCount: Int
    var isLiked: Bool
    var replyCount: Int
    let parentCommentId: String?
    let createdAt: String
}
