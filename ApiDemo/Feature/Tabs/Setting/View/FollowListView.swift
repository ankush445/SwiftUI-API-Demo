//
//  FollowListView.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//

import SwiftUI
struct FollowListView: View {
    @Environment(NavigationManager.self) private var nav

    @State private var vm: FollowListViewModel
    init(viewModel: FollowListViewModel) {
        self.vm = viewModel
    }
    
    var body: some View {
        VStack(spacing: 8) {
            headerView()
            
          
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    CustomSearchBar(text: $vm.searchText, placeholder: AppStrings.search)
                        .padding(.horizontal)
                        .onChange(of: vm.searchText) { _, newValue in
                            if newValue.isEmpty {
                                Task { await vm.switchTab(vm.selectedTab) } // reload normal data
                            } else {
                                vm.scheduleSearch()
                            }
                        }
                    if vm.selectedTab == .followers {
                        listView(users: vm.followers, loadMore: vm.fetchFollowers)
                    } else {
                        listView(users: vm.following, loadMore: vm.fetchFollowing)
                    }
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
        .background(Color.appBackground)
        .navigationBarBackButtonHidden()
        .loadingIndicator(
            isLoading: vm.isLoading &&
            ((vm.selectedTab == .followers && vm.followerCursor == nil) ||
             (vm.selectedTab == .following && vm.followingCursor == nil))
        )
        .task {
            await vm.loadInitial()
        }
    }
    
    
    
    @ViewBuilder
    func headerView() -> some View {
        VStack(spacing: 6) {   // 🔥 reduced spacing
            
            // Top bar
            HStack {
                CustomBackButton(title: nil) {
                    nav.pop()
                }
                .frame(width: 44, alignment: .leading)
                
                Spacer()
                
                Text(vm.username)
                    .customFont(.semiBold, 18)
                    .foregroundStyle(.primaryText)// slightly smaller
                
                Spacer()
                
                Color.clear.frame(width: 44)
            }
            .padding(.horizontal)
            .frame(height: 44) // 🔥 fixed height
            
            // Tabs
            FollowTopBar(selected: vm.selectedTab) { tab in
                Task { await vm.switchTab(tab) }
            }
            
            Divider()
                .padding(.top, -8)
           
        }
        .background(Color.appSecondaryBackground)
    }
    @ViewBuilder
    func listView(
        users: [FollowerModel],
        loadMore: @escaping () async -> Void
    ) -> some View {
        
        // 🔥 EMPTY STATE
        if users.isEmpty && !vm.isLoading {
            VStack(spacing: 12) {
                
                Image(systemName: "person.2")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                Text(emptyTitle)
                    .customFont(.semiBold, 14)
                    .foregroundStyle(.primaryText)
                
                Text(emptySubtitle)
                    .customFont(.regular, 12)
                    .foregroundStyle(.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
        }
        
        // ✅ LIST
        ForEach(users) { user in
            
            FollowerRow(user: user, follower: vm.selectedTab == .followers) {
                Task{
                    if vm.selectedTab == .followers {
                        await vm.toggleFollow(user: user)
                    } else {
                        await vm.unfollowUser(user)
                    }
                }
            } onRemove: {
                Task {
                    if vm.selectedTab == .followers {
                        await vm.removeFollower(user)
                    }
                }
            }
            .onAppear {
                if user.id == users.last?.id {
                    Task { await loadMore() }
                }
            }
        }
        
        // 🔄 PAGINATION LOADER
        if vm.isLoading && users.isEmpty == false {
            ProgressView()
                .padding(.vertical, 16)
        }
    }
    
    private var emptyTitle: String {
        if !vm.searchText.isEmpty {
            return AppStrings.noResults
        }
        
        return vm.selectedTab == .followers
        ? AppStrings.noFollowers
        : AppStrings.noFollowing
    }

    private var emptySubtitle: String {
        if !vm.searchText.isEmpty {
            return AppStrings.tryDifferentKeyword
        }
        
        return vm.selectedTab == .followers
        ? AppStrings.noFollowersSubtitle
        : AppStrings.noFollowingSubtitle
    }
}
