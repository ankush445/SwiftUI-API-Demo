//
//  ResetPasswordView.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//


import SwiftUI
import SwiftUI_Loader
import FancyToastKit

struct ResetPasswordView: View {
    @Environment(NavigationManager.self) private var nav

    @State var viewModel: AuthViewModel
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color(.appBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Spacer(minLength: 40)
                    .frame(height: 40)
                
                Text(AppStrings.resetPassword)
                    .customFont(.bold, 24)
                
                VStack(spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(AppStrings.newPassword)
                            .customFont(.semiBold, 14)
                            .foregroundColor(Color.textFieldIconBackground)
                        
                        SecureInputField(
                            icon: "lock",
                            placeholder: AppStrings.newPassword,
                            text: $viewModel.password
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(AppStrings.confirmPassword)
                            .customFont(.semiBold, 14)
                            .foregroundColor(Color.textFieldIconBackground)
                        
                        SecureInputField(
                            icon: "lock",
                            placeholder: AppStrings.confirmPassword,
                            text: $viewModel.confirmPassword
                        )
                    }
                    
                    CustomButton(title: AppStrings.updatePassword) {
                        Task {
                            let result  = await viewModel.resetPassword()
                            if result {
                                nav.popToLogin()
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
    ResetPasswordView(
        viewModel: AuthViewModel(
            repository: AppDI.shared.authRepository
        ))
    
}
