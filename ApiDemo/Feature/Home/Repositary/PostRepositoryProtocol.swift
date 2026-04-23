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
    func likePost(id: String) async throws -> LikeModel
    func addComment(postId: String, text: String) async throws -> CommentResponse

    func getComments(postId: String, cursor: String?) async throws -> CommentListResponse
    func getReplies(commentId: String, cursor: String?) async throws -> CommentListResponse

    
    func addReply(postId: String,parentId: String,text: String) async throws -> CommentResponse
    func likeComment(commentId: String) async throws -> LikeModel
    func fetchUserPosts(cursor: String?, search: String?,userId:String) async throws -> PostListResponse

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
    
    func likePost(id: String) async throws -> LikeModel {
        return try await networkService.request(APIEndpoint.postLike(id: id), responseType: LikeModel.self)
    }
    
    func addComment(postId: String, text: String) async throws -> CommentResponse {
        return try await networkService.request(APIEndpoint.addComment(postId: postId, text: text), responseType: CommentResponse.self)
    }
    func addReply(postId: String,parentId: String, text: String
    ) async throws -> CommentResponse {
        
        return try await networkService.request(
            APIEndpoint.addReply(
                postId: postId,
                parentId: parentId,
                text: text
            ),
            responseType: CommentResponse.self
        )
    }
    
    func getComments(postId: String, cursor: String?) async throws -> CommentListResponse {
        return try await networkService.request(APIEndpoint.getComment(postId: postId, cursor: cursor), responseType: CommentListResponse.self)
    }
    
    func getReplies(commentId: String, cursor: String?) async throws -> CommentListResponse {
        return try await networkService.request(APIEndpoint.getRepliesComment(commentId: commentId, cursor: cursor), responseType: CommentListResponse.self)
    }
    
    func likeComment(commentId: String) async throws -> LikeModel {
        try await networkService.request(
            APIEndpoint.commentLike(commentId:commentId),
            responseType: LikeModel.self
        )
    }
    
    func fetchUserPosts(cursor: String?, search: String?, userId:String) async throws -> PostListResponse {
        return try await networkService.request(
            APIEndpoint.getUserPosts(cursor: cursor, search: search, limit: 10, id: userId),
            responseType: PostListResponse.self
        )
    }
}
