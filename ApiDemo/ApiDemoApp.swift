//
//  ApiDemoApp.swift
//  ApiDemo
//
//  Created by ios-22 on 11/03/26.
//

import SwiftUI

import SwiftUI

@main
struct ApiDemoApp: App {
    
    private let userViewModel: UserViewModel
    
    init() {
        
        // Token Storage
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
        self.userViewModel = UserViewModel(
            repository: userRepository
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: userViewModel)
        }
    }
}
