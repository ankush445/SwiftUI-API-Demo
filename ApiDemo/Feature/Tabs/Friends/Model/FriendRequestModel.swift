//
//  FriendRequestModel.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import Foundation

struct FriendRequestResponse: Codable {
    let success: Bool
    let message: String?
    let data: [FriendRequestModel]
    let nextCursor: String?
    let hasMore: Bool
}

struct FriendRequestModel: Codable, Identifiable {
    let id: String
    let requester: User
    let status: String
    let createdAt: String
    
    // 🔥 UI state
    var isLoading: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case requester
        case status
        case createdAt
    }
}
