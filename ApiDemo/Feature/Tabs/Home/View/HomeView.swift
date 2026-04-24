//
//  HomeView.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import SwiftUI
import SwiftUI_Loader
import FancyToastKit
struct HomeView: View {
    
    @State private var vm: HomeViewModel
    
    @Bindable var session: SessionManager  // ✅ works perfectly with @Observable

    @State private var showCreatePost = false
    @State private var navigateToSettings = false
    @State private var selectedPost: Post?
    
    let storyUsers = ["You", "Elena", "Marcus", "Sasha", "Julian"]
    
    init(viewModel: HomeViewModel, session: SessionManager) {
        _vm = State(wrappedValue: viewModel)
        self.session = session
    }
    
    var body: some View {
     
        VStack{
            // 📜 Feed
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
            
                       
                    storiesView
                        .padding(.top, 16)
                    // 🔥 SHIMMER (FIRST LOAD)
                    if vm.isInitialLoading {
                        ForEach(0..<5, id: \.self) { _ in
                            PostCardShimmer()
                        }
                    }
                    
                    // ✅ REAL DATA
                    else if !vm.posts.isEmpty {
                        ForEach(vm.posts) { post in
                            PostCardView(
                                post: post,
                                onLike: {
                                    vm.toggleLike(post: post)
                                },
                                onComment: {
                                    selectedPost = post
                                }
                            )
                            .onAppear {
                                if post.id == vm.posts.last?.id {
                                    Task { await vm.fetchPosts() }
                                }
                            }
                        }
                        
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
                            
                            Text("No posts yet")
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
            
            
        }
        .loadingIndicator(isLoading: (vm.isLoading && vm.nextCursor == nil))
        .navigationBarHidden(false) // 👈 Important: show nav bar
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    
                } label: {
                    
                    
                    Image(systemName: "camera")
                        .customFont(.semiBold, 20)
                        .foregroundStyle(.buttonBackground)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(AppStrings.appName)
                    .customFont(.semiBold, 18)
                    .foregroundStyle(.primaryText)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // action
                } label: {
                    Image(systemName: "bell")
                        .customFont(.semiBold, 20)
                        .foregroundStyle(.textFieldIconBackground)
                }
            }
          
        }
        .toolbarBackground(Color.appSecondaryBackground, for: .navigationBar) // Set navigation background color
        .toolbarBackground(.visible, for: .navigationBar)
        
        // Make sure it's visible
        // 🔍 Search
//        .searchable(text: $vm.searchText)
//        .onChange(of: vm.searchText) { _, _ in
//            vm.scheduleSearch()
//        }
        .task {
            await vm.loadPosts()
        }
//        .sheet(isPresented: $showCreatePost) {
//            CreatePostView(session: session) { title, desc in
//                Task {
//                    await vm.createPost(title: title, description: desc)
//                }
//            }
//        }
        .sheet(item: $selectedPost) { post in
            CommentView(post: post, viewModel: CommentViewModel(repository: AppDI.shared.postRepository), session: session)
                .presentationDetents([.medium, .large]) // ✅ medium + expandable
                .presentationDragIndicator(.visible)    // ✅ top indicator
                .presentationCornerRadius(20)           // ✅ modern rounded sheet
                .interactiveDismissDisabled(false)
        }
//        .navigationDestination(isPresented: $navigateToSettings) {
//            SettingsView(viewModel: SettingViewModel(repository: AppDI.shared.settingRepository, session: session), session: session)
//        }
//        .toastView(toast: $vm.toast)
        .onReceive(NotificationCenter.default.publisher(for: .commentUpdated)) { notification in
            
            guard let postId = notification.userInfo?["postId"] as? String else { return }
            
            if let index = vm.posts.firstIndex(where: { $0.id == postId }) {
                vm.posts[index].commentCount += 1
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
