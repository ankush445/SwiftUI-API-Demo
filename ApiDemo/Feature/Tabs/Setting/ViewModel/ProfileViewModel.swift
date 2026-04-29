//
//  ProfileViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//
import SwiftUI
import Observation

@Observable
final class ProfileViewModel: ToastPresentable {
    
    var toast: FancyToast?
    
    private let repository: ProfileRepositaryProtocol
    
    private let followRepositary: FollowersRepositoryProtocol

    let userId: String
    
    var profile: ProfileModel?
   
    var posts: [Post] = []
    
    var isLoading = false
    var isInitialLoading = true
    
    var nextCursor: String?
    private var hasMore = true
    private var likingIds: Set<String> = []
    var isFollowLoading = false
    private var previousStatus: FollowStatus?

    init(repository: ProfileRepositaryProtocol, followRepositary: FollowersRepositoryProtocol, userId: String) {
        self.repository = repository
        self.followRepositary = followRepositary
        self.userId = userId
    }
    
    // MARK: - Initial Load
    @MainActor
    func loadProfile() async {
        guard !isLoading else { return }
        
        isInitialLoading = true
        reset()
        
        await fetchProfile()
        
        isInitialLoading = false
    }
    
    // MARK: - Fetch / Pagination
    @MainActor
    func fetchProfile() async {
        guard !isLoading, hasMore else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.getUserProfile(
                id: userId,
                cursor: nextCursor
            )
            
            if nextCursor == nil {
                // 🔥 First load
                profile = response.user.toDomain()
                posts = response.posts
            } else {
                // 🔁 Pagination
                posts.append(contentsOf: response.posts)
            }
            
            hasMore = response.hasMore
            nextCursor = response.nextCursor
            
        } catch {
            toast = FancyToast(type: .error, title: "Error", message: error.localizedDescription)
        }
    }
    
    // MARK: - Reset
    private func reset() {
        profile = nil
        posts = []
        
        nextCursor = nil
        hasMore = true
        
        isLoading = false
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadProfile()
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
    
    
    @MainActor
    func performAction() async {
        
        guard let userId = profile?.id,
              let currentStatus = profile?.followStatus,
              !isFollowLoading else { return }
        
        isFollowLoading = true
        
        // 🔥 store previous ONLY when going to pending
        if currentStatus == .none || currentStatus == .follower {
            previousStatus = currentStatus
        }
        
        // 🔥 Optimistic UI
        profile?.followStatus = nextState(from: currentStatus)
        
        do {
            switch currentStatus {
                
            case .none, .follower:
                _ = try await followRepositary.sendFollowRequest(id: userId)
                
            case .pending:
                _ = try await followRepositary.cancelRequest(id: userId)
                
            case .following, .mutual:
                _ = try await followRepositary.unfollow(id: userId)
            }
            
            isFollowLoading = false
            
        } catch {
            // rollback
            profile?.followStatus = currentStatus
            isFollowLoading = false
            showError(error)
        }
    }
    
    private func nextState(from status: FollowStatus) -> FollowStatus {
        
        switch status {
            
        case .none:
            return .pending
            
        case .follower:
            return .pending   // follow back request
            
        case .pending:
            // 🔥 THIS IS YOUR MAIN REQUIREMENT
            return previousStatus == .follower ? .follower : .none
            
        case .following:
            return .none
            
        case .mutual:
            return .following
        }
    }
}
