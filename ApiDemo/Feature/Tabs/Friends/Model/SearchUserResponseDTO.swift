//
//  SearchUserResponseDTO.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import Foundation
struct SearchUserResponseDTO: Codable {
    let success: Bool
    let message: String?
    let users: [SearchUserDTO]
    let nextCursor: String?
    let hasMore: Bool
}

struct SearchUserDTO: Codable {
    let id: String
    let name: String
    let username: String
    let followStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case username
        case followStatus
    }
}
struct SearchUserModel: Identifiable {
    let id: String
    let name: String
    let username: String
    var followStatus: FollowStatus
    
    // UI state
    var isLoading: Bool = false
}

extension SearchUserDTO {
    func toDomain() -> SearchUserModel {
        return SearchUserModel(
            id: id,
            name: name,
            username: username,
            followStatus: FollowStatus(rawValue: followStatus) ?? .none
        )
    }
}
