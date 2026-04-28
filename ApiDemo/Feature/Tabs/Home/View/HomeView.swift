//
//  HomeView.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import SwiftUI
struct HomeView: View {
    @Environment(NavigationManager.self) private var nav

    @State private var vm: HomeViewModel
    
    @Bindable var session: SessionManager  // ✅ works perfectly with @Observable

    @State private var showCreatePost = false
    @State private var navigateToSettings = false
    @State private var selectedPost: Post?
    
    // For Scrolling
    @State private var naturalScrollOffset:CGFloat = 0
    @State private var lastNaturalOffset:CGFloat = 0
    @State private var headerOffset:CGFloat = 0
    @State private var isScrollingUp:Bool = false

    let storyUsers = ["You", "Elena", "Marcus", "Sasha", "Julian"]
    
    init(viewModel: HomeViewModel, session: SessionManager) {
        _vm = State(wrappedValue: viewModel)
        self.session = session
    }
    
    var body: some View {
        
        
        GeometryReader{
            let safeArea = $0.safeAreaInsets
            let headerHeight = 110 + safeArea.top
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    
                    // 🔥 SHIMMER (FIRST LOAD)
                    if vm.isInitialLoading {
                        ForEach(0..<5, id: \.self) { _ in
                            PostCardShimmer()
                        }
                    }
                    
                    // ✅ REAL DATA
                    else if !vm.posts.isEmpty {
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
                                },
                                onTapProfile: {
                                    nav.pushUserProfile(userID: post.user.id)
                                }
                            )
                            .onAppear {
                                if post.id == vm.posts.last?.id {
                                    Task { await vm.fetchPosts() }
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
                .padding(.top, 0)
            }
            .scrollContentBackground(.hidden) // Hides the default background for the List
            .background(Color.appBackground) // Custom background for the List
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
        .onAppear {
            // Only load if posts are empty (first time)
            if vm.posts.isEmpty && !vm.isInitialLoading {
                Task {
                    await vm.loadPosts()
                }
            }
        }
        .task {
            // Only load on first appearance
            if vm.posts.isEmpty {
                await vm.loadPosts()
            }
        }
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
    func headerView()-> some  View{
        
        VStack(spacing: 10){
            HStack{
                Button {
                    
                } label: {
                    
                    
                    Image(systemName: "camera")
                        .customFont(.semiBold, 20)
                        .foregroundStyle(.buttonBackground)
                }
                Spacer()
                Text(AppStrings.appName)
                    .customFont(.semiBold, 20)
                    .foregroundStyle(.primaryText)
                Spacer()
                Button {
                    // action
                } label: {
                    Image(systemName: "bell")
                        .customFont(.semiBold, 20)
                        .foregroundStyle(.textFieldIconBackground)
                }
            }
            .padding(.horizontal)

            
            CustomSearchBar(text: $vm.searchText, placeholder: AppStrings.search)
                .padding(.horizontal)
                .onChange(of: vm.searchText) { oldValue, newValue in
                    vm.scheduleSearch()
                }
        }
    }

    var storiesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                
                ForEach(storyUsers, id: \.self) { user in
                    VStack(spacing: 6) {
                        
                        ZStack {
                            Circle()
                                .stroke(Color.buttonBackground, lineWidth: 2)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .fill(dynamicColor(for: user))
                                .frame(width: 50, height: 50)
                            
                            Text(String(user.prefix(1)))
                                .foregroundColor(.white)
                                .customFont(.semiBold, 16)
                        }
                        
                        Text(user)
                            .customFont(.medium, 14)
                            .foregroundStyle(.primaryText)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        repository: AppDI.shared.postRepository
    ), session: SessionManager.shared)
}
