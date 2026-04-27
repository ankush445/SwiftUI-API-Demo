//
//  FriendView.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import SwiftUI
struct FriendView: View {
    
    @State private var vm: FriendViewModel
    
    @Environment(NavigationManager.self) private var nav

    
    
    // scroll handling (reuse same logic)
    @State private var naturalScrollOffset: CGFloat = 0
    @State private var lastNaturalOffset: CGFloat = 0
    @State private var headerOffset: CGFloat = 0
    @State private var isScrollingUp: Bool = false
    
    init(viewModel: FriendViewModel) {
        self.vm = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geo in
            let safeArea = geo.safeAreaInsets
            let headerHeight = 110 + safeArea.top
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    
                    Spacer().frame(height: 10)
                    
                    
                    if vm.isInitialLoading {
                        ForEach(0..<6, id: \.self) { _ in
                            FriendRequestShimmerRow()
                        }
                    }else if !vm.searchText.isEmpty {
                        searchResultSection   // 🔥 NEW
                    } else if vm.friendRequests.isEmpty && vm.suggestedFriends.isEmpty {
                        
                        VStack(spacing: 12) {
                            Image(systemName: "person.2")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text(AppStrings.noFriendsYet)
                                .customFont(.medium, 14)
                                .foregroundStyle(.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        // 🔥 Friend Requests
                        if !vm.friendRequests.isEmpty {
                            friendRequestSection
                        }
                        
                        // 👥 Suggested Friends
                        suggestedFriendsSection
                    }
                }
                .padding(.horizontal)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .refreshable {
                await Task.detached {
                    await vm.refresh()
                }.value
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                headerView()
                    .padding(.bottom, 15)
                    .frame(height: headerHeight, alignment: .bottom)
                    .background(Color.appSecondaryBackground)
                    .offset(y: -headerOffset)
                    .clipped() // 👈 important
                
            }
            .onScrollGeometryChange(for: CGFloat.self) { proxy in
                let maxHeight = proxy.contentSize.height - proxy.containerSize.height
                return max(min(proxy.contentOffset.y + headerHeight, maxHeight), 0)
            } action: { oldValue, newValue in
                let isScrollingUp = oldValue < newValue
                headerOffset = min(max(newValue - lastNaturalOffset,0), headerHeight)
                self.isScrollingUp = isScrollingUp
                naturalScrollOffset = newValue
            }
            .onChange(of: isScrollingUp, { oldValue, newValue in
                lastNaturalOffset = naturalScrollOffset - headerOffset
            })
            .ignoresSafeArea(.container, edges: .top)
           
        }
        .loadingIndicator(isLoading: (vm.isLoading && vm.suggestFriendNextCursor == nil))
        .toastView(toast: $vm.toast)
        .task {
            await vm.loadFriends()
        }
    }
    
    @ViewBuilder
    func headerView()-> some  View{
        
        VStack(spacing: 10){
            HStack{
                
                Spacer()
                Text(AppStrings.friends)
                    .customFont(.semiBold, 20)
                    .foregroundStyle(.primaryText)
                Spacer()
            }
            .padding(.horizontal)
            
            
            CustomSearchBar(text: $vm.searchText, placeholder: AppStrings.search)
                .padding(.horizontal)
                .onChange(of: vm.searchText) { oldValue, newValue in
                    vm.scheduleSearch()
                }
        }
    }
    
    
    var friendRequestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                Text(AppStrings.friendRequests)
                    .customFont(.semiBold, 18)
                    .foregroundStyle(.primaryText)
                
                Spacer()
                Button{
                    nav.pushFriend(FriendRoute.FriendRequest)
                } label: {
                    Text(AppStrings.seeAll)
                        .customFont(.medium, 14)
                        .foregroundStyle(.likeBackground)
                }
                
            }
            
            
            ForEach(vm.friendRequests) { request in
                FriendRequestRow(
                    request: request,
                    onAccept: {
                        Task { await vm.acceptRequest(request) }
                    },
                    onReject: {
                        Task { await vm.rejectRequest(request) }
                    }
                )
            }
        }
    }
    var suggestedFriendsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(AppStrings.suggested)
                .customFont(.semiBold, 18)
                .foregroundStyle(.primaryText)
            
            ForEach(vm.suggestedFriends) { suggestUser in
                SuggestedFriendRow(suggestUser: suggestUser) {
                    Task{
                        await vm.toggleFollow(user: suggestUser)
                    }
                }
                .onAppear {
                    if suggestUser.id == vm.suggestedFriends.last?.id {
                        Task { await vm.fetchSuggestFriends() }
                    }
                }
            }
        }
    }
    
    var searchResultSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(AppStrings.results)
                .customFont(.semiBold, 16)
                .foregroundStyle(.primaryText)
            
            if vm.searchResults.isEmpty && !vm.isLoading {
                
                // 🔥 EMPTY STATE
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text(AppStrings.noUsersFound)
                        .customFont(.medium, 14)
                        .foregroundStyle(.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            }
            
            ForEach(vm.searchResults) { user in
                SearchUserRow(user: user) {
                    Task {
                        await vm.toggleSearchFollow(user: user)
                    }
                }
                .onAppear {
                    if user.id == vm.searchResults.last?.id {
                        Task { await vm.searchUsers() }
                    }
                }
            }
        }
    }
}

