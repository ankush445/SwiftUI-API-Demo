//
//  FollowersViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//

import SwiftUI
import Foundation

enum FollowTab {
    case followers
    case following
}
@Observable
final class FollowListViewModel {
    
    private let repository: FollowersRepositoryProtocol
    let userId: String
    let username: String

    
    var selectedTab: FollowTab = .followers
    
    var followers: [FollowerModel] = []
    var following: [FollowerModel] = []
    var searchText: String = ""
    var isLoading = false
    
    var followerCursor: String?
    var followingCursor: String?
    
    private var followerHasMore = true
    private var followingHasMore = true
    
    private var searchTask: Task<Void, Never>?
    
    init(repository: FollowersRepositoryProtocol, userId: String, username: String, selectedTab :FollowTab = .followers) {
        self.repository = repository
        self.userId = userId
        self.username = username
        self.selectedTab = selectedTab
    }
    
    // MARK: Load Initial
    @MainActor
    func loadInitial() async {
        await self.selectedTab == .followers ? fetchFollowers() : fetchFollowing()
    }
    
    // MARK: Followers
    @MainActor
    func fetchFollowers() async {
        guard !isLoading, followerHasMore else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let res = try await repository.getFollowers(id: userId, cursor: followerCursor, searchText: searchText)
            
            if followerCursor == nil {
                followers = res.data.map({ model in
                    model.toDomain()
                })
            } else {
                followers.append(contentsOf: res.data.map({ model in
                    model.toDomain()
                }))
            }
            
            followerCursor = res.nextCursor
            followerHasMore = res.hasMore
            
        } catch {
            print(error)
        }
    }
    
    // MARK: Following
    @MainActor
    func fetchFollowing() async {
        guard !isLoading, followingHasMore else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let res = try await repository.getFollowing(id: userId, cursor: followingCursor, searchText: searchText)
            
            if followingCursor == nil {
                following = res.data.map({ model in
                    model.toDomain()
                })
            } else {
                following.append(contentsOf: res.data.map({ model in
                    model.toDomain()
                }))
            }
            
            followingCursor = res.nextCursor
            followingHasMore = res.hasMore
            
        } catch {
            print(error)
        }
    }
    
    // MARK: Tab Switch
    @MainActor
    func switchTab(_ tab: FollowTab) async {
        selectedTab = tab
        
        if tab == .followers && followers.isEmpty {
            await fetchFollowers()
        }
        
        if tab == .following && following.isEmpty {
            await fetchFollowing()
        }
    }
    
    func scheduleSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
    
    @MainActor
    func performSearch() async {
        
        resetPaginationForSearch()
        
        if selectedTab == .followers {
            await fetchFollowers()
        } else {
            await fetchFollowing()
        }
    }
    
    private func resetPaginationForSearch() {
        if selectedTab == .followers {
            followerCursor = nil
            followerHasMore = true
            followers = []
        } else {
            followingCursor = nil
            followingHasMore = true
            following = []
        }
    }
    
    @MainActor
    func toggleFollow(user: FollowerModel) async {
        
        guard let index = followers.firstIndex(where: { $0.id == user.id }) else { return }
        
        followers[index].isLoading = true
        
        defer {
            followers[index].isLoading = false
        }
        
        do {
            switch followers[index].relationType {
                
            case .follower:
                let _ = try await repository.sendFollowRequest(id: user.id)
                followers[index].relationType = .pending
                
            case .pending:
                let _ = try await repository.cancelRequest(id: user.id)
                followers[index].relationType = .follower
            default:
                return
            }
            
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func removeFollower(_ user: FollowerModel) async {
        
        guard let index = followers.firstIndex(where: { $0.id == user.id }) else { return }
        
        followers[index].isLoading = true
        
        do {
            _ = try await repository.removeFollower(id: user.id)
            
           _ = withAnimation {
                followers.remove(at: index)
            }
            
        } catch {
            followers[index].isLoading = false
        }
    }
    
    @MainActor
    func unfollowUser(_ user: FollowerModel) async {
        
        guard let index = following.firstIndex(where: { $0.id == user.id }) else { return }
        
        following[index].isLoading = true
        
        do {
            _ = try await repository.unfollow(id: user.id)
            
            _ = withAnimation {
                following.remove(at: index)
            }
            
        } catch {
            following[index].isLoading = false
        }
    }
}
