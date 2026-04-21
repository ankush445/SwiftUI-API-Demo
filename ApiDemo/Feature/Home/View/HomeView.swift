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
    
    init(viewModel: HomeViewModel, session: SessionManager) {
            _vm = State(wrappedValue: viewModel)
            self.session = session
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🌈 Background Gradient (modern feel)
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 📜 Feed
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        
                        // ✅ Empty State
                        if vm.posts.isEmpty && !vm.isLoading {
                            Spacer()
                            VStack(spacing: 10) {
                                Image(systemName: "tray")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                
                                Text("No posts yet")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 100)
                            Spacer()
                        }
                        
                        // ✅ Posts
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
                                // 🔄 Pagination trigger
                                if post.id == vm.posts.last?.id {
                                    Task { await vm.fetchPosts() }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                }
                .refreshable {
                    await Task.detached {
                        await vm.refresh()
                    }.value
                }
                
                // ➕ Floating Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button {
                            showCreatePost = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        }
                        .padding()
                    }
                }
            }
            .loadingIndicator(isLoading: vm.isLoading)
            .navigationTitle("Feed")
            .toolbar {
                
                
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigateToSettings = true
                    } label: {
                        if let user = session.user {
                            ZStack {
                                Circle()
                                    .fill(dynamicColor(for: user.name))
                                    .frame(width: 36, height: 36)
                                    .shadow(radius: 2)

                                Text(user.name.prefix(1))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 36, height: 36)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            // 🔍 Search
            .searchable(text: $vm.searchText)
            .onChange(of: vm.searchText) { _, _ in
                vm.scheduleSearch()
            }
            .task {
                await vm.loadPosts()
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView(session: session) { title, desc in
                    Task {
                        await vm.createPost(title: title, description: desc)
                    }
                }
            }
            .sheet(item: $selectedPost) { post in
                CommentView(post: post, vm: vm, session: session)
                    .presentationDetents([.medium, .large]) // ✅ medium + expandable
                    .presentationDragIndicator(.visible)    // ✅ top indicator
                    .presentationCornerRadius(20)           // ✅ modern rounded sheet
                    .interactiveDismissDisabled(false)
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView(viewModel: SettingViewModel(repository: AppDI.shared.settingRepository, session: session), session: session)
            }
            .toastView(toast: $vm.toast)

        }
    }
}

// MARK: - Helper

private extension HomeView {
    
    func dynamicColor(for name: String) -> Color {
        let hash = abs(name.hashValue)
        let hue = Double(hash % 256) / 255.0
        return Color(hue: hue, saturation: 0.6, brightness: 0.8)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        repository: AppDI.shared.postRepository
    ), session: SessionManager.shared)
}
