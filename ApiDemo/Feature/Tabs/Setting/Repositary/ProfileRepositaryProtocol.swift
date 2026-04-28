//
//  ProfileRepositaryProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//


import Foundation

protocol ProfileRepositaryProtocol{
    
    func getUserProfile(id: String, cursor: String?) async throws -> ProfileResponseDTO
    func likePost(id: String) async throws -> LikeModel
  
}

final class ProfileRepositary: ProfileRepositaryProtocol {
   
    
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    func getUserProfile(id: String, cursor: String?) async throws -> ProfileResponseDTO {
        return try await networkService.request(
            APIEndpoint.getUserProfile(id: id, cursor: cursor, limit: 10),
            responseType: ProfileResponseDTO.self
        )
    }
    
    func likePost(id: String) async throws -> LikeModel {
        return try await networkService.request(APIEndpoint.postLike(id: id), responseType: LikeModel.self)
    }
    
    func getFollowers(id: String, cursor: String?, searchText: String?) async throws -> FollowersResponseDTO {
        return try await networkService.request(APIEndpoint.getFollowers(id: id, search: searchText, cursor: cursor, limit: 10), responseType: FollowersResponseDTO.self)
    }
    
    func getFollowing(id: String, cursor: String?, searchText: String?) async throws -> FollowersResponseDTO {
        return try await networkService.request(APIEndpoint.getFollowing(id: id, search: searchText, cursor: cursor, limit: 10), responseType: FollowersResponseDTO.self)
    }
}
