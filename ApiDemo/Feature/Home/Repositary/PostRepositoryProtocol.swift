//
//  PostRepositoryProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import Foundation

protocol PostRepositoryProtocol {
    func fetchPosts(cursor: String?, search: String?) async throws -> PostListResponse
    func createPost(title: String, description: String?) async throws -> PostModel
    func likePost(id: String) async throws -> PostLikeModel
    func addComment(postId: String, text: String) async throws -> CommentResponse

    func getComments(postId: String) async throws -> CommentListResponse

}

final class PostRepository: PostRepositoryProtocol {

    

    
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    func fetchPosts(cursor: String?, search: String?) async throws -> PostListResponse {
        return try await networkService.request(
            APIEndpoint.getFeed(cursor: cursor, search: search, limit: 10),
            responseType: PostListResponse.self
        )
    }
    func createPost(title: String, description: String?) async throws -> PostModel {
        return try await networkService.request(APIEndpoint.createPost(title: title, content: description), responseType: PostModel.self)
    }
    
    func likePost(id: String) async throws -> PostLikeModel {
        return try await networkService.request(APIEndpoint.postLike(id: id), responseType: PostLikeModel.self)
    }
    
    func addComment(postId: String, text: String) async throws -> CommentResponse {
        return try await networkService.request(APIEndpoint.addComment(postId: postId, text: text), responseType: CommentResponse.self)
    }
    
    func getComments(postId: String) async throws -> CommentListResponse {
        return try await networkService.request(APIEndpoint.getComment(postId: postId), responseType: CommentListResponse.self)
    }
    
}
