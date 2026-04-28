//
//  FollowerModel.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//

import Foundation

struct FollowersResponseDTO: Codable {
    let success: Bool
    let message: String?
    let data: [FollowerDTO]
    let nextCursor: String?
    let hasMore: Bool
}
struct FollowerDTO: Codable {
    let id: String
    let name: String
    let username: String
    let relationType: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case username
        case relationType
        case createdAt
    }
}

struct FollowerModel: Identifiable {
    let id: String
    let name: String
    let username: String
    var relationType: FollowingStatus
    
    // UI state
    var isLoading: Bool = false
}

extension FollowerDTO {
    func toDomain() -> FollowerModel {
        return FollowerModel(
            id: id,
            name: name,
            username: username,
            relationType: FollowingStatus(rawValue: relationType) ?? .follower
        )
    }
}

enum FollowingStatus: String {
    case pending
    case follower
    case mutual
    case following
    
}
