import SwiftUI

struct AuthView: View {
    
    @State private var vm: AuthViewModel
    
    @Environment(NavigationManager.self) private var nav
    
    init(viewModel: AuthViewModel) {
        _vm = State(wrappedValue: viewModel)
    }

    var body: some View {
            ZStack {
                
                // Background
                Color(.appBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        Spacer(minLength: 40)
                        
                        // MARK: - Logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    Color.buttonBackground
                                )
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 28))
                        }
                        
                        // MARK: - Title
                        Text(AppStrings.appName)
                            .customFont(.bold, 28)
                        
                        Text(vm.isLoginMode
                             ? AppStrings.loginSubtitle
                             : AppStrings.signupSubtitle)
                        .customFont(.medium, 15)
                        .foregroundStyle(Color.textFieldIconBackground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        
                        // MARK: - Card
                        VStack(spacing: 18) {
                            
                            if !vm.isLoginMode {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(AppStrings.fullName)
                                        .customFont(.semiBold, 14)
                                        .foregroundStyle(Color.textFieldIconBackground)
                                    inputField(
                                        icon: "person",
                                        placeholder: AppStrings.fullName,
                                        text: $vm.name
                                    )
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(AppStrings.username)
                                        .customFont(.semiBold, 14)
                                        .foregroundStyle(Color.textFieldIconBackground)
                                    inputField(
                                        icon: "at",
                                        placeholder: AppStrings.username,
                                        text: $vm.username
                                    )
                                    .onChange(of: vm.username) { _,_  in
                                        vm.checkUsernameAvailabilityDebounced()
                                    }
                                    usernameStatusView
                                    
                                }
                                
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppStrings.email)
                                    .customFont(.semiBold, 14)
                                    .foregroundStyle(Color.textFieldIconBackground)
                                inputField(
                                    icon: "envelope",
                                    placeholder: AppStrings.email,
                                    text: $vm.email
                                )
                            }
                            
                            // Password Section
                            VStack(alignment: .leading, spacing: 6) {
                                Text(AppStrings.password)
                                    .customFont(.semiBold, 14)
                                    .foregroundStyle(Color.textFieldIconBackground)
                                SecureInputField(
                                    icon: "lock",
                                    placeholder: AppStrings.password,
                                    text: $vm.password
                                )
                                
                                HStack {
                                    Spacer()
                                    
                                    if vm.isLoginMode {
                                        Button {
                                            nav.showForgotPassword()
                                        } label: {
                                            Text(AppStrings.forgotPassword)
                                                .customFont(.semiBold, 14)
                                                .foregroundStyle(.likeBackground)
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Button
                            CustomButton(title: vm.isLoginMode ? AppStrings.login : AppStrings.signUp) {
                                hideKeyboard()
                                Task {
                                    if vm.isLoginMode {
                                        await vm.loginUser()
                                    } else {
                                        await vm.createUser()
                                    }
                                }
                            }
                            .disabled(
                                vm.isAuthButtonDisabled
                            )
                            
                        }
                        .padding(20)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10)
                        
                        // MARK: - Toggle
                        HStack {
                            Text(vm.isLoginMode
                                 ? AppStrings.noAccount
                                 : AppStrings.alreadyAccount)
                            .customFont(.medium, 14)
                            .foregroundStyle(Color.textFieldIconBackground)
                            
                            
                            Button {
                                withAnimation {
                                    vm.isLoginMode.toggle()
                                    vm.resetFields()
                                }
                            } label: {
                                Text(vm.isLoginMode
                                     ? AppStrings.signUp
                                     : AppStrings.login)
                                .foregroundStyle(.likeBackground)
                                .customFont(.semiBold, 14)
                            }
                        }
                        .font(.footnote)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .toastView(toast: $vm.toast)
            .loadingIndicator(isLoading: vm.isLoading)
    }
    
    
    var usernameStatusView: some View {
        HStack(spacing: 6) {
            
            switch vm.usernameState {
                
            case .checking:
                ProgressView()
                    .scaleEffect(0.7)
                
                Text(AppStrings.checking)
                    .customFont(.regular, 12)
                    .foregroundColor(.gray)
                
            case .available:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text(AppStrings.usernameAvailable)
                    .customFont(.regular, 12)
                    .foregroundColor(.green)
                
            case .taken:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                
                Text(AppStrings.usernameTaken)
                    .customFont(.regular, 12)
                    .foregroundColor(.red)
                
            case .invalid(let message):
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                
                Text(message) // 👈 dynamic message from API
                    .customFont(.regular, 12)
                    .foregroundColor(.orange)
                
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut, value: vm.usernameState) // 👈 BEST PLACE

    }
}

#Preview {
    AuthView(
        viewModel: AuthViewModel(
            repository: AppDI.shared.authRepository
        )
    )
}
