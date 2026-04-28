//
//  FriendRequestView.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//


import SwiftUI
struct FriendRequestView: View {
    @Environment(NavigationManager.self) private var nav

    @State private var vm: FriendViewModel

    
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
            let headerHeight = 60 + safeArea.top
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    
                    Spacer().frame(height: 10)
                    
                    if vm.isInitialLoading {
                        ForEach(0..<6, id: \.self) { _ in
                            FriendRequestShimmerRow()
                        }
                    }
                      
                      // ✅ REAL DATA
                      else {
                          friendRequestSection
                      }
                        
                    Spacer().frame(height: 40)

                     
    
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
        .loadingIndicator(isLoading: (vm.isLoading && vm.requestNextCursor == nil))
        .toastView(toast: $vm.toast)
        .task {
            await vm.loadFriendRequest()
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    func headerView() -> some View {
        
        VStack(spacing: 10) {
            HStack {
                
                // 👈 Left (Back)
                CustomBackButton(title: nil) {
                    nav.pop()
                }
                .frame(width: 44, alignment: .leading) // fixed width
                
                Spacer()
                
                // 🎯 Center Title
                Text(AppStrings.friendRequests)
                    .customFont(.semiBold, 20)
                    .foregroundStyle(.primaryText)
                
                Spacer()
                
                // 👉 Right (dummy to balance)
                Color.clear
                    .frame(width: 44) // same width as left
            }
            .padding(.horizontal)
        }
    }

    
    var friendRequestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            ForEach(vm.friendRequests) { request in
                FriendRequestRow(
                    request: request,
                    onAccept: {
                        Task { await vm.acceptRequest(request) }
                    },
                    onReject: {
                        Task { await vm.rejectRequest(request) }
                    }, onTapProfile: {
                        nav.pushFriend(FriendRoute.userProfile(userID: request.requester.id))
                    }
                )
                .onAppear{
                    if request.id == vm.friendRequests.last?.id {
                        Task { await vm.fetchFriendRequests() }
                    }
                }
            }
            
            if vm.requestNextCursor != nil && vm.isLoading {
                ProgressView()
            }
            
        }
    }
}



