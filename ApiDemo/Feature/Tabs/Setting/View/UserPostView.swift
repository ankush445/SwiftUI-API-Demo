//
//  MyPostView.swift
//  ApiDemo
//
//  Created by ios-22 on 22/04/26.
//

//import SwiftUI
//struct UserPostView: View {
//    
//    @State private var vm: UserPostViewModel
//    @Bindable var session: SessionManager  // ✅ works perfectly with @Observable
//    @State private var selectedPost: Post?
//    
//    init(viewModel: UserPostViewModel, session: SessionManager) {
//        _vm = State(wrappedValue: viewModel)
//        self.session = session
//    }
//    
//    var body: some View {
//        ZStack {
//            // 🌈 Background Gradient (modern feel)
//            LinearGradient(
//                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            // 📜 Feed
//            ScrollView(showsIndicators: false) {
//                LazyVStack(spacing: 16) {
//                    
//                    // 🔥 SHIMMER (FIRST LOAD)
//                    if vm.isInitialLoading {
//                        ForEach(0..<5, id: \.self) { _ in
//                            PostCardShimmer()
//                        }
//                    }
//                    
//                    // ✅ REAL DATA
//                    else if !vm.posts.isEmpty {
//                        ForEach(vm.posts) { post in
//                            PostCardView(
//                                post: post,
//                                onLike: {
//                                    vm.toggleLike(post: post)
//                                },
//                                onComment: {
//                                    selectedPost = post
//                                }
//                            )
//                            .onAppear {
//                                if post.id == vm.posts.last?.id {
//                                    Task { await vm.fetchUserPosts() }
//                                }
//                            }
//                        }
//                        
//                        if vm.nextCursor != nil && vm.isLoading {
//                            ProgressView()
//                        }
//                    }
//                    
//                    // ❌ EMPTY STATE
//                    else {
//                        VStack(spacing: 10) {
//                            Image(systemName: "tray")
//                                .font(.largeTitle)
//                                .foregroundColor(.gray)
//                            
//                            Text("No posts yet")
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.top, 100)
//                    }
//                }
//                 .padding(.horizontal)
//                .padding(.top, 0)
//            }
//            .refreshable {
//                await Task.detached {
//                    await vm.refresh()
//                }.value
//            }
//        }
//        .loadingIndicator(isLoading: (vm.isLoading && vm.nextCursor == nil))
//        .navigationTitle("My Post")
//        .searchable(text: $vm.searchText)
//        .onChange(of: vm.searchText) { _, _ in
//            vm.scheduleSearch()
//        }
//        .onAppear {
//            Task {
//                await vm.loadPosts()
//            }
//        }
//        .sheet(item: $selectedPost) { post in
//            CommentView(post: post, viewModel: CommentViewModel(repository: AppDI.shared.postRepository), session: session)
//                .presentationDetents([.medium, .large]) // ✅ medium + expandable
//                .presentationDragIndicator(.visible)    // ✅ top indicator
//                .presentationCornerRadius(20)           // ✅ modern rounded sheet
//                .interactiveDismissDisabled(false)
//        }
//        .onReceive(NotificationCenter.default.publisher(for: .commentUpdated)) { notification in
//            
//            guard let postId = notification.userInfo?["postId"] as? String else { return }
//            
//            if let index = vm.posts.firstIndex(where: { $0.id == postId }) {
//                vm.posts[index].commentCount += 1
//            }
//        }
//    }
//}
//
//#Preview {
//    UserPostView(viewModel: UserPostViewModel(
//        repository: AppDI.shared.postRepository,userId: ""
//    ), session: SessionManager.shared)
//}
