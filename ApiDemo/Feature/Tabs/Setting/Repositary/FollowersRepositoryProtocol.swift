//
//  FollowersRepositoryProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//


protocol FollowersRepositoryProtocol {
    func getFollowers(id: String, cursor: String?, searchText: String?) async throws -> FollowersResponseDTO
    func getFollowing(id: String, cursor: String?, searchText: String?) async throws -> FollowersResponseDTO
    func sendFollowRequest(id:String) async throws -> PostModel
    func unfollow(id: String) async throws -> PostModel
    func cancelRequest(id: String) async throws -> PostModel
    func removeFollower(id: String) async throws -> PostModel


}

final class FollowersRepository: FollowersRepositoryProtocol {
   
    
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getFollowers(id: String, cursor: String?, searchText: String?) async throws -> FollowersResponseDTO {
        return try await networkService.request(APIEndpoint.getFollowers(id: id, search: searchText, cursor: cursor, limit: 10), responseType: FollowersResponseDTO.self)
    }
    
    func getFollowing(id: String, cursor: String?, searchText: String?) async throws -> FollowersResponseDTO {
        return try await networkService.request(APIEndpoint.getFollowing(id: id, search: searchText, cursor: cursor, limit: 10), responseType: FollowersResponseDTO.self)
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
    func removeFollower(id: String) async throws -> PostModel {
        return try await networkService.request(APIEndpoint.removeFollower(id: id), responseType: PostModel.self)
    }
}
