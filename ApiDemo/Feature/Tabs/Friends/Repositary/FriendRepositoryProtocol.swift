//
//  FriendRepositoryProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//


import Foundation

protocol FriendRepositoryProtocol{
    func getSuggestFriends(cursor: String?) async throws -> SuggestListResponse
    func sendFollowRequest(id:String) async throws -> PostModel
    func unfollow(id: String) async throws -> PostModel
    func cancelRequest(id: String) async throws -> PostModel
    func getPendingRequest(cursor:String?) async throws -> FriendRequestResponse
    func respondRequest(id: String, action: String) async throws -> PostModel
    func searchUsers(searchText: String?, cursor: String?) async throws -> SearchUserResponseDTO
}

final class FriendRepository: FriendRepositoryProtocol {
   
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    func getSuggestFriends(cursor: String?) async throws -> SuggestListResponse {
        return try await networkService.request(
            APIEndpoint.getSuggestUser(cursor: cursor, limit: 10),
            responseType: SuggestListResponse.self
        )
    }
    func sendFollowRequest(id: String) async throws -> PostModel {
        return try await networkService.request(APIEndpoint.sendFollowRequest(id: id), responseType: PostModel.self)
    }
    func unfollow(id: String) async throws -> PostModel {
        return try await networkService.request(APIEndpoint.unfollow(id: id), responseType: PostModel.self)
    }
    
    func cancelRequest(id: String) async throws -> PostModel {
        return try await networkService.request(APIEndpoint.cancelFollowRequest(id: id), responseType: PostModel.self)
    }
    
    func getPendingRequest(cursor: String?) async throws -> FriendRequestResponse {
        return try await networkService.request(APIEndpoint.getPendingRequests(cursor: cursor, limit: 10), responseType: FriendRequestResponse.self)
    }
    
    func respondRequest(id: String, action: String) async throws -> PostModel {
        return try await networkService.request(APIEndpoint.respondPendingRequest(id: id, action: action), responseType: PostModel.self)
    }
    func searchUsers(searchText: String?, cursor: String?) async throws -> SearchUserResponseDTO {
        return try await networkService.request(APIEndpoint.searchUser(search: searchText, cursor: cursor, limit: 10), responseType: SearchUserResponseDTO.self)
    }
}
