//
//  HomeViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import SwiftUI
import Observation
import FancyToastKit
@Observable
final class HomeViewModel: ToastPresentable {
    
    var posts: [Post] = []
    var isLoading = false
    var searchText = ""
    var toast: FancyToast?

    
    private let repository: PostRepositoryProtocol
    
    private var nextCursor: String?
    private var hasMore = true
    private var searchTask: Task<Void, Never>?
    private var likingIds: Set<String> = []

    init(repository: PostRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Initial Load
    
    func loadPosts() async {
        reset()
        await fetchPosts()
    }
    
    // MARK: - Pagination
    
    func fetchPosts() async {
        guard !isLoading, hasMore else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.fetchPosts(
                cursor: nextCursor,
                search:searchText
            )
            
            posts.append(contentsOf: response.posts)
            nextCursor = response.nextCursor
            hasMore = response.hasMore
            
        } catch {
            print(error)
        }
    }
    // MARK: - Refresh Data
    
    func refresh() async {
        await loadPosts()
    }
    
    // MARK: - Search
    
    func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await search()
        }
    }
    
    func search() async {
        await loadPosts()
    }
    
    // MARK: - Reset
    
    private func reset() {
        posts = []
        nextCursor = nil
        hasMore = true
    }
    
    
    // MARK: - Create Post
    func createPost(title: String, description: String?) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.createPost(title: title, description: description)
            await MainActor.run {
                showSuccess(message: response.message ?? "Post Created Successfully")
            }
        } catch {
            await MainActor.run {
                showError(error)
            }
        }
    }
    
    // MARK: - Like
    func toggleLike(post: Post) {
        
        guard !likingIds.contains(post.id) else { return }
        likingIds.insert(post.id)
        
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
            likingIds.remove(post.id)
            return
        }
        
        let oldIsLiked = posts[index].isLiked
        let oldLikeCount = posts[index].likeCount
        
        // 🔥 Optimistic update
        posts[index].isLiked.toggle()
        posts[index].likeCount += posts[index].isLiked ? 1 : -1
        
        // 🔥 HAPTIC (instant feedback)
        HapticManager.trigger(posts[index].isLiked ? .medium : .soft)
        
        Task {
            defer {
                likingIds.remove(post.id)
            }
            
            do {
                _ = try await repository.likePost(id: post.id)
                
            } catch {
                await MainActor.run {
                    // ❌ Rollback
                    posts[index].isLiked = oldIsLiked
                    posts[index].likeCount = oldLikeCount
                    
                    HapticManager.trigger(.error) // ❌ error feedback
                    showError(error)
                }
            }
        }
    }
    


//    // MARK: - Get Comments
//   
//    // MARK: - Add Comment
//    func addComment(postId: String, text: String) {
//        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//        
//        Task {
//            do {
//                let response = try await repository.addComment(postId: postId, text: text)
//                
//                await MainActor.run {
//                    // 🔥 Insert instantly
//                    comments.insert(response.data, at: 0)
//                    
//                    // 🔥 Update post comment count
//                    if let index = posts.firstIndex(where: { $0.id == postId }) {
//                        posts[index].commentCount += 1
//                    }
//                    
//                    HapticManager.trigger(.light)
//                }
//                
//            } catch {
//                await MainActor.run {
//                    showError(error)
//                }
//            }
//        }
//    }
//    
//    func addReply(postId: String, parentId: String, text: String) {
//        Task {
//            do {
//                let response = try await repository.addReply(
//                    postId: postId,
//                    parentId: parentId,
//                    text: text
//                )
//                
//                await MainActor.run {
//                    comments.insert(response.data, at: 0)
//                }
//                
//            } catch {
//                await MainActor.run {
//                    showError(error)
//                }
//            }
//        }
//    }
}
