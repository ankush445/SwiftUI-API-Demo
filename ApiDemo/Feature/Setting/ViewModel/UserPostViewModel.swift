//
//  PostViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//

import SwiftUI
import Observation
import FancyToastKit
@Observable
final class UserPostViewModel: ToastPresentable {
    
    var posts: [Post] = []
    var isLoading = false
    var searchText = ""
    var toast: FancyToast?
    var isInitialLoading = true

    private let userId: String
    private let repository: PostRepositoryProtocol
    
    var nextCursor: String?
    private var hasMore = true
    private var searchTask: Task<Void, Never>?
    private var likingIds: Set<String> = []

    init(repository: PostRepositoryProtocol, userId: String) {
        self.repository = repository
        self.userId = userId
    }
    
    // MARK: - Initial Load
    func loadPosts() async {
        isInitialLoading = true
        reset()
        await fetchUserPosts()
        await MainActor.run {
            isInitialLoading = false
        }
    }
    // MARK: - Pagination
    
    func fetchUserPosts() async {
        guard !isLoading, hasMore else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.fetchUserPosts(
                cursor: nextCursor,
                search:searchText,
                userId: userId
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
}
