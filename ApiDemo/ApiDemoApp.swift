//
//  ApiDemoApp.swift
//  ApiDemo
//
//  Created by ios-22 on 11/03/26.
//
import SwiftUI
@main
struct ApiDemoApp: App {
    @State var session = SessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                HomeView(
                    viewModel: HomeViewModel(
                        repository: AppDI.shared.postRepository
                    ), session: session
                )
              
            } else {
                AuthView(
                    viewModel: AuthViewModel(
                        repository: AppDI.shared.authRepository
                    )
                )
            }
        }
    }
}
