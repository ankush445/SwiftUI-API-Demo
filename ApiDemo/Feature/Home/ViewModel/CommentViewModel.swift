//
//  CommentViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 22/04/26.
//

import SwiftUI
import Observation

@Observable
final class CommentViewModel {
    
    // MARK: - Comments
    
    var comments: [Comment] = []
    var isLoading = false
    
    private var commentCursor: String?
    private var hasMoreComments = true
    private var isFetchingComments = false
    
    // MARK: - Replies
    
    var repliesMap: [String: [Comment]] = [:]
    var replyCursor: [String: String?] = [:]
    var hasMoreReplies: [String: Bool] = [:]
    var loadingReplies: Set<String> = []
    var expandedComments: Set<String> = []
    
    var replyingTo: Comment? = nil
    
    private let repository: PostRepositoryProtocol
    
    init(repository: PostRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchComments(postId: String) async {
        comments = []
        commentCursor = nil
        hasMoreComments = true
        
        await fetchMoreComments(postId: postId)
    }
    
    func fetchMoreComments(postId: String) async {
        
        guard !isFetchingComments, hasMoreComments else { return }
        
        isFetchingComments = true
        isLoading = true
        
        defer {
            isFetchingComments = false
            isLoading = false
        }
        
        do {
            let response = try await repository.getComments(
                postId: postId,
                cursor: commentCursor
            )
            
            await MainActor.run {
                let newComments = response.data
                comments.append(contentsOf: newComments)
                
                commentCursor = response.nextCursor
                hasMoreComments = response.hasMore
            }
            
        } catch {
            print(error)
        }
    }
    func toggleReplies(commentId: String) {
        if expandedComments.contains(commentId) {
            expandedComments.remove(commentId)
        } else {
            expandedComments.insert(commentId)
        }
    }
    
    func fetchReplies(commentId: String) async {
        
        guard !loadingReplies.contains(commentId) else { return }
        
        loadingReplies.insert(commentId)
        
        defer { loadingReplies.remove(commentId) }
        
        do {
            let response = try await repository.getReplies(
                commentId: commentId,
                cursor: replyCursor[commentId] ?? nil
            )
            
            await MainActor.run {
                
                let newReplies = response.data
                
                if repliesMap[commentId] != nil {
                    repliesMap[commentId]! += newReplies
                } else {
                    repliesMap[commentId] = newReplies
                }
                
                replyCursor[commentId] = response.nextCursor
                hasMoreReplies[commentId] = response.hasMore
            }
            
        } catch {
            print(error)
        }
    }
    func addComment(postId: String, text: String) async {
        do {
            let response = try await repository.addComment(postId: postId, text: text)
            
            await MainActor.run {
                comments.insert(response.data, at: 0)
                
                NotificationCenter.default.post(
                    name: .commentUpdated,
                    object: nil,
                    userInfo: ["postId": postId]
                )
            }
            
        } catch {
            print(error)
        }
    }
    
    func addReply(postId: String, parentId: String, text: String) async {
        guard let index = comments.firstIndex(where: { $0.id == parentId }) else { return }
        
        // 🔹 Store old state (for rollback)
        let oldReplyCount = comments[index].replyCount
        let oldReplies = repliesMap[parentId] ?? []
        do {
            let response = try await repository.addReply(
                postId: postId,
                parentId: parentId,
                text: text
            )
            
            await MainActor.run {
                repliesMap[parentId, default: []].insert(response.data, at: 0)
                comments[index].replyCount += 1
                
                // 🔥 ALSO update comment count
                NotificationCenter.default.post(
                    name: .commentUpdated,
                    object: nil,
                    userInfo: ["postId": postId]
                )
            }
            
        } catch {
            print(error)
        }
    }
    
    func toggleLike(commentId: String) {
        
        // 🔹 Track where the comment is (main or reply)
        var parentKey: String? = nil
        var index: Int? = nil
        var isReply = false
        
        // 🔍 Find in main comments
        if let i = comments.firstIndex(where: { $0.id == commentId }) {
            index = i
        } else {
            // 🔍 Find in replies
            for (key, replies) in repliesMap {
                if let i = replies.firstIndex(where: { $0.id == commentId }) {
                    parentKey = key
                    index = i
                    isReply = true
                    break
                }
            }
        }
        
        guard let idx = index else { return }
        
        // 🔹 Store old state (for rollback)
        let oldIsLiked: Bool
        let oldLikeCount: Int
        
        if isReply {
            oldIsLiked = repliesMap[parentKey!]![idx].isLiked
            oldLikeCount = repliesMap[parentKey!]![idx].likeCount
        } else {
            oldIsLiked = comments[idx].isLiked
            oldLikeCount = comments[idx].likeCount
        }
        
        // 🔥 Optimistic update
        if isReply {
            repliesMap[parentKey!]![idx].isLiked.toggle()
            repliesMap[parentKey!]![idx].likeCount += repliesMap[parentKey!]![idx].isLiked ? 1 : -1
        } else {
            comments[idx].isLiked.toggle()
            comments[idx].likeCount += comments[idx].isLiked ? 1 : -1
        }
        
        // 🔥 API call
        Task {
            do {
               _ = try await repository.likeComment(commentId: commentId)
            } catch {
                
                // ❌ Rollback if failed
                await MainActor.run {
                    if isReply {
                        repliesMap[parentKey!]![idx].isLiked = oldIsLiked
                        repliesMap[parentKey!]![idx].likeCount = oldLikeCount
                    } else {
                        comments[idx].isLiked = oldIsLiked
                        comments[idx].likeCount = oldLikeCount
                    }
                }
            }
        }
    }
}
