//
//  ContentView.swift
//  ApiDemo
//
//  Created by ios-22 on 11/03/26.
//

import SwiftUI
import SwiftUI_Loader
struct ContentView: View {
    
    @StateObject var viewModel: UserViewModel

    var body: some View {
        NavigationStack {
            ZStack {
            if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(.red)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchUsers()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.users.isEmpty {
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
