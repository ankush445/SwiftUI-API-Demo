//
//  ProfileView.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//


import SwiftUI

struct ProfileView: View {
    @Environment(NavigationManager.self) private var nav
    @Environment(SessionManager.self) private var session

    @State private var showCreatePost = false
    @State private var navigateToSettings = false
    @State private var selectedPost: Post?

    @State private var vm: ProfileViewModel
       
    
    // scroll handling (reuse same logic)
    @State private var naturalScrollOffset: CGFloat = 0
    @State private var lastNaturalOffset: CGFloat = 0
    @State private var headerOffset: CGFloat = 0
    @State private var isScrollingUp: Bool = false
    init(viewModel: ProfileViewModel) {
        self.vm = viewModel
    }
    var body: some View {
        GeometryReader { geo in
            let safeArea = geo.safeAreaInsets
            let headerHeight = 60 + safeArea.top
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    
                    Spacer().frame(height: 10)
                    // 👤 Profile Header
                    profileHeader
                    
                    Divider()
                    
                    // 📝 Posts (Single Column)
                    if !vm.posts.isEmpty {
                        Spacer()
                            .frame(height: 10)
                        ForEach(vm.posts) { post in
                            PostCardView(
                                post: post,
                                onLike: {
                                    vm.toggleLike(post: post)
                                },
                                onComment: {
                                    selectedPost = post
                                }, onTapProfile: { }
                            )
                            .onAppear {
                                if post.id == vm.posts.last?.id {
                                    Task { await vm.fetchProfile() }
                                }
                            }
                        }
                        Spacer()
                            .frame(height: 40)
                        
                        if vm.nextCursor != nil && vm.isLoading {
                            ProgressView()
                        }
                    }
                    
                    // ❌ EMPTY STATE
                    else {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            Text(AppStrings.noPostYet)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 100)
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
        .loadingIndicator(isLoading: (vm.isLoading && vm.nextCursor == nil))
        .toastView(toast: $vm.toast)
        
        .task {
            await vm.loadProfile()
        }
        .navigationBarBackButtonHidden()
        .sheet(item: $selectedPost) { post in
            CommentView(post: post, viewModel: CommentViewModel(repository: AppDI.shared.postRepository), session: session)
                .presentationDetents([.medium, .large]) // ✅ medium + expandable
                .presentationDragIndicator(.visible)    // ✅ top indicator
                .presentationCornerRadius(20)           // ✅ modern rounded sheet
                .interactiveDismissDisabled(false)
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .commentUpdated)) { notification in
            
            guard let postId = notification.userInfo?["postId"] as? String else { return }
            
            if let index = vm.posts.firstIndex(where: { $0.id == postId }) {
                vm.posts[index].commentCount += 1
            }
        }

    }
    
    @ViewBuilder
    func headerView() -> some View {
        
        VStack(spacing: 10) {
            HStack {
                
                // 👈 Left (Back)
                if vm.profile?.id != session.user?.id {
                    CustomBackButton(title: nil) {
                        nav.pop()
                    }
                    .frame(width: 44, alignment: .leading) // fixed width
                }
                
                Spacer()
                
                // 🎯 Center Title
                Text(vm.profile?.username ?? AppStrings.profile)
                    .customFont(.semiBold, 20)
                    .foregroundStyle(.primaryText)
                
                Spacer()
                
                // 👉 Right (dummy to balance)
                if vm.profile?.id != session.user?.id {
                    
                    Color.clear
                        .frame(width: 44) // same width as left
                }
            }
            .padding(.horizontal)
        }
    }
    var profileHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // 👤 Top Row (Avatar + Stats)
            HStack(alignment: .center, spacing: 20) {
                
                // Avatar
                Text(vm.profile?.name.prefix(1) ?? "A")
                    .customFont(.bold, 26)
                    .frame(width: 85, height: 85)
                    .background(dynamicColor(for: vm.profile?.name ?? "A"))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                
                // Stats
                HStack {
                    statView(count: formatCount(vm.profile?.postCount ?? 0), title: AppStrings.posts)
                    statView(count: formatCount(vm.profile?.followers ?? 0), title: AppStrings.followers)
                        .onTapGesture {
                            nav.pushFollowers(userId: vm.profile?.id ?? "", username: vm.profile?.username ?? "", selectedTab: 0)
                        }
                    statView(count: formatCount(vm.profile?.following ?? 0), title: AppStrings.following)
                        .onTapGesture {
                            nav.pushFollowers(userId: vm.profile?.id ?? "", username: vm.profile?.username ?? "", selectedTab: 1)
                            
                        }
                }
                .frame(maxWidth: .infinity)
            }
            
            // 👤 Name
            Text(vm.profile?.name ?? "Unknown User")
                .customFont(.semiBold, 16)
                .foregroundStyle(.primaryText)
            
            // 📝 Bio
            Text("Visual Storyteller & UX Designer 🎨\nCapturing the world through a minimalist lens.\nBased in Tokyo. 🇯🇵")
                .customFont(.regular, 14)
                .foregroundStyle(.secondaryText)
            
            // 🔗 Link
            Text("linktr.ee/elenaro")
                .customFont(.regular, 14)
                .foregroundColor(.blue)
            
            // 🏷 Username
            Text("@\(vm.profile?.username ?? "unknown_user")")
                .customFont(.medium, 14)
                .foregroundStyle(.secondaryText)
            
            // 🎯 Action Button
            actionButtons
        }
    }
    
    func statView(count: String, title: String) -> some View {
        VStack(spacing: 2) {
            Text(count)
                .customFont(.bold, 20)
                .foregroundStyle(.primaryText)
            
            Text(title)
                .customFont(.regular, 14)
                .foregroundStyle(.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
    var actionButtons: some View {
        Group {
            if vm.profile?.id == session.user?.id {
                
                HStack(spacing: 10) {
                    Button(AppStrings.editProfile) { }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.buttonBackground)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                            .frame(width: 42, height: 42)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
            } else {
                
                Button(buttonTitle) {
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    vm.profile?.followStatus == FollowStatus.none
                    ? Color.buttonBackground
                    : Color.gray.opacity(0.15)
                )
                .foregroundColor(
                    vm.profile?.followStatus == FollowStatus.none
                    ? .white
                    : .primaryText
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private var buttonTitle: String {
        if let followStatus = vm.profile?.followStatus{
            switch followStatus {
            case .none: return AppStrings.follow
            case .pending: return AppStrings.requested
            case .following: return AppStrings.unfollow
            case .follower: return AppStrings.followBack
            case .mutual: return AppStrings.message
            }
        } else {
            return AppStrings.follow
        }
    }
}

#Preview {
    ProfileView(viewModel: ProfileViewModel(repository: AppDI.shared.profileRepository, userId: ""))
}
