//
//  Model.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import Foundation


// POST Like Model
struct SuggestListResponse: Codable {
    let success: Bool
    let message: String?
    let users: [SuggestFriendModel]
    let nextCursor: String?
    let hasMore: Bool
}
enum FollowStatus: String {
    case none
    case pending
    case following
}

struct SuggestFriendModel: Codable, Identifiable {
    let id : String
    let name: String
    let username: String
    let mutualCount: Int
    let mutualUsers: [User]
    
    // 🔥 UI STATE (not from API)
      var followStatus: FollowStatus = .none
      var isLoading: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"   // ✅ mapping fix
        case name
        case username
        case mutualCount
        case mutualUsers
    }
}


