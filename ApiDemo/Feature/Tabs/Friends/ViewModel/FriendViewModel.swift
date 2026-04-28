//
//  FriendViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import SwiftUI
import Observation
@Observable
final class FriendViewModel: ToastPresentable {
    
    private let repository: FriendRepositoryProtocol
    var searchText: String = ""
    
    var friendRequests: [FriendRequestModel] = []
    var suggestedFriends: [SuggestFriendModel] = []
    var searchResults: [SearchUserModel] = []
    var isLoading = false
    var toast: FancyToast?
    var isInitialLoading = true

    var suggestFriendNextCursor: String?
    private var suggestFriendHasMore = true
    
    var requestNextCursor: String?
    private var requestHasMore = true
    
    private var searchTask: Task<Void, Never>?
    var searchNextCursor: String?
    private var searchHasMore = true
    
    init(repository: FriendRepositoryProtocol) {
        self.repository = repository
    }
    
    
    func loadFriends() async {
        isInitialLoading = true
        reset()
        
        await fetchFriendRequests()   // 🔥 add this
        await fetchSuggestFriends()
        
        await MainActor.run {
            isInitialLoading = false
        }
    }
    func loadFriendRequest() async {
        isInitialLoading = true
        reset()
        
        await fetchFriendRequests()   // 🔥 add this
        await MainActor.run {
            isInitialLoading = false
        }
    }
    
    func refresh() async {
        await loadFriends()
    }
    
    // MARK: - Pagination
    @MainActor
    func fetchSuggestFriends() async {
        guard !isLoading, suggestFriendHasMore else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.getSuggestFriends(
                cursor: suggestFriendNextCursor,
            )
            
            suggestedFriends.append(contentsOf: response.users)
            suggestFriendNextCursor = response.nextCursor
            suggestFriendHasMore = response.hasMore
            
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func fetchFriendRequests() async {
        
        guard !isLoading, requestHasMore else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.getPendingRequest(
                cursor: requestNextCursor
            )
            
            if requestNextCursor == nil {
                // first load
                friendRequests = response.data
            } else {
                friendRequests.append(contentsOf: response.data)
            }
            
            requestNextCursor = response.nextCursor
            requestHasMore = response.hasMore
            
        } catch {
            print(error)
        }
    }
    
    private func reset() {
        
        // ❌ Cancel any running search task
        searchTask?.cancel()
        searchTask = nil
        
        // 🔍 Search
        searchText = ""
        searchResults = []
        searchNextCursor = nil
        searchHasMore = true
        
        // 👥 Suggested
        suggestedFriends = []
        suggestFriendNextCursor = nil
        suggestFriendHasMore = true
        
        // 📩 Requests
        friendRequests = []
        requestNextCursor = nil
        requestHasMore = true
        
        // ⚡ States
        isLoading = false
    }
    
    @MainActor
    func acceptRequest(_ request: FriendRequestModel) async {
        
        guard let index = friendRequests.firstIndex(where: { $0.id == request.id }) else { return }
        
        friendRequests[index].isLoading = true
        
        do {
            _ = try await repository.respondRequest(id: request.id, action: "accepted")
            // remove from list
            _ = withAnimation(.easeInOut) {
                friendRequests.remove(at: index)
            }
        } catch {
            friendRequests[index].isLoading = false
        }
    }

    @MainActor
    func rejectRequest(_ request: FriendRequestModel) async {
        
        guard let index = friendRequests.firstIndex(where: { $0.id == request.id }) else { return }
        
        friendRequests[index].isLoading = true
        
        do {
            _ = try await repository.respondRequest(id: request.id, action: "rejected")
            
            _ = withAnimation(.easeInOut) {
                friendRequests.remove(at: index)
            }
        } catch {
            friendRequests[index].isLoading = false
        }
    }
    
    @MainActor
    func toggleFollow(user: SuggestFriendModel) async {
        
        guard let index = suggestedFriends.firstIndex(where: { $0.id == user.id }) else { return }
        
        suggestedFriends[index].isLoading = true
        
        defer {
            suggestedFriends[index].isLoading = false
        }
        
        do {
            switch suggestedFriends[index].followStatus {
                
            case .none:
                let _ = try await repository.sendFollowRequest(id: user.id)
                suggestedFriends[index].followStatus = .pending
                
            case .pending:
                let _ = try await repository.cancelRequest(id: user.id)
                suggestedFriends[index].followStatus = .none
                
            case .following:
                let _ = try await repository.unfollow(id: user.id)
                suggestedFriends[index].followStatus = .none
            case .follower:
                let _ = try await repository.sendFollowRequest(id: user.id)
                suggestedFriends[index].followStatus = .pending
            case .mutual:
                print("message functionality implement here")
            }
            
        } catch {
            print(error)
        }
    }
    
    func scheduleSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
            
            if !Task.isCancelled {
                await searchUsers()
            }
        }
    }
    
    
    @MainActor
    func searchUsers() async {
        
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            
            let response = try await repository.searchUsers(searchText: searchText, cursor: searchNextCursor)
            
            if searchNextCursor == nil {
                searchResults = response.users.map { $0.toDomain() }

            }else {
                searchResults.append(contentsOf: response.users.map { $0.toDomain() })
            }
            searchNextCursor = response.nextCursor
            searchHasMore = response.hasMore
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func toggleSearchFollow(user: SearchUserModel) async {
        
        guard let index = searchResults.firstIndex(where: { $0.id == user.id }) else { return }
        
        searchResults[index].isLoading = true
        
        defer {
            searchResults[index].isLoading = false
        }
        
        do {
            switch searchResults[index].followStatus {
            case .none:
                _ = try await repository.sendFollowRequest(id: user.id)
                searchResults[index].followStatus = .pending
                
            case .pending:
                _ = try await repository.cancelRequest(id: user.id)
                searchResults[index].followStatus = .none
                
            case .following:
               _ = try await repository.unfollow(id: user.id)
                searchResults[index].followStatus = .none
            case .follower:
                _ = try await repository.sendFollowRequest(id: user.id)
                searchResults[index].followStatus = .pending
            case .mutual:
                print("message comming soon")
            }
        } catch {
            print(error)
        }
    }
}
