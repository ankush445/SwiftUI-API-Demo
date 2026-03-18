//
//  ContentView.swift
//  ApiDemo
//
//  Created by ios-22 on 11/03/26.
//

import SwiftUI
import SwiftUI_Loader
import FancyToastKit
struct ContentView: View {
    
    @StateObject var viewModel: UserViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.users.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.gray)
                        Text("No Users")
                            .font(.headline)
                    }
                } else {
                    List(viewModel.users) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.fetchUsers()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.fetchUsers()
            }
            .loadingIndicator(isLoading: viewModel.isLoading, message: "")
            .toastView(toast: $viewModel.toast)
        }
    }
}

#Preview {
    let tokenStorage = UserDefaultsTokenStorage()
    
    // Auth Service
    let authService = AuthService(
        session: .shared,
        tokenStorage: tokenStorage
    )
    
    // Network Layer
    let networkService = NetworkService(
        session: .shared,
        tokenStorage: tokenStorage,
        authService: authService
    )
    
    // Repository Layer
    let userRepository = UserRepository(
        networkService: networkService
    )
    
    // ViewModel
    let userViewModel = UserViewModel(
        repository: userRepository
    )
    ContentView(viewModel: userViewModel)
}
