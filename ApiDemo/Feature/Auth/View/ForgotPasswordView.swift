//
//  ForgotPasswordView.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//

import SwiftUI
import SwiftUI_Loader
import FancyToastKit
struct ForgotPasswordView: View {
    
    @State var viewModel: AuthViewModel
    @Environment(NavigationManager.self) private var nav

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color(.appBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Spacer(minLength: 40)
                    .frame(height: 40)
                
                Text(AppStrings.forgotPassword)
                    .customFont(.bold, 24)

                Text(AppStrings.resetPasswordSubtitle)
                    .customFont(.regular, 14)
                    .foregroundColor(Color.textFieldIconBackground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(AppStrings.email)
                            .customFont(.semiBold, 14)
                            .foregroundColor(Color.textFieldIconBackground)
                        
                        inputField(
                            icon: "envelope",
                            placeholder: AppStrings.email,
                            text: $viewModel.email
                        )
                    }
                    
                    CustomButton(title: AppStrings.resetPassword) {
                        Task {
                           let result = await viewModel.sendResetEmail()
                            if result {
                                nav.showResetPassword()
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.appSecondaryBackground)
                .cornerRadius(20)
                
                Spacer()
            }
            .padding()
        }
        .customBackButton(action: {
            nav.authPop()
        })
        .toastView(toast: $viewModel.toast)
        .loadingIndicator(isLoading: viewModel.isLoading)
    }
}
#Preview {
    ForgotPasswordView(
        viewModel: AuthViewModel(
            repository: AppDI.shared.authRepository
        ))
    
}

