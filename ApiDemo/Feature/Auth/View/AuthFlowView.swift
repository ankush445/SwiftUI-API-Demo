//
//  AuthFlowView.swift
//  ApiDemo
//
//  Created by ios-22 on 24/04/26.
//

import SwiftUI
struct AuthFlowView: View {
    @Environment(NavigationManager.self) private var nav
 
    var body: some View {
        @Bindable var nav = nav   // needed to bind @Observable property to NavigationStack
 
        NavigationStack(path: $nav.authPath) {
            AuthView(
                viewModel: AuthViewModel(
                    repository: AppDI.shared.authRepository
                )
            )
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .forgotPassword:
                        ForgotPasswordView(viewModel: AuthViewModel(
                            repository: AppDI.shared.authRepository
                        ))
                    case .resetPassword:
                        ResetPasswordView(viewModel: AuthViewModel(
                            repository: AppDI.shared.authRepository
                        ))
                    }
                }
        }
    }
}
