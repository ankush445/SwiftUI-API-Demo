import SwiftUI
import FancyToastKit

struct AuthView: View {
    
    @State private var vm: AuthViewModel
    @State private var isLogin = true
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password
    }

    init(viewModel: AuthViewModel) {
        _vm = State(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            // 🌈 Background Gradient (modern feel)
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    Spacer(minLength: 40)
                    
                    // 🧠 Title
                    Text(isLogin ? "Welcome Back 👋" : "Create Account 🚀")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    // 📦 Card Container
                    VStack(spacing: 16) {
                        
                        if !isLogin {
                            customTextField(
                                title: "Name",
                                text: $vm.name,
                                field: .name
                            )
                        }
                        
                        customTextField(
                            title: "Email",
                            text: $vm.email,
                            field: .email,
                            keyboard: .emailAddress
                        )
                        
                        customSecureField(
                            title: "Password",
                            text: $vm.password,
                            field: .password
                        )
                        
                        // 🚀 Action Button
                        Button {
                            hideKeyboard()
                            Task {
                                if isLogin {
                                    await vm.loginUser(
                                        email: vm.email,
                                        password: vm.password
                                    )
                                } else {
                                    await vm.createUser(
                                        name: vm.name,
                                        email: vm.email,
                                        password: vm.password
                                    )
                                }
                            }
                        } label: {
                            if vm.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text(isLogin ? "Login" : "Sign Up")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(vm.email.isEmpty || vm.password.isEmpty || (!isLogin && vm.name.isEmpty))
                        
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    
                    // 🔁 Toggle
                    Button {
                        withAnimation {
                            isLogin.toggle()
                            vm.resetFields()
                        }
                    } label: {
                        Text(isLogin
                             ? "Don't have an account? Sign Up"
                             : "Already have an account? Login")
                            .foregroundColor(.white)
                            .font(.footnote)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onTapGesture {
            hideKeyboard() // 👈 dismiss on tap
        }
        .toastView(toast: $vm.toast)
    }
}

extension AuthView {
    
    func customTextField(
        title: String,
        text: Binding<String>,
        field: Field,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        TextField(title, text: text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: field)
    }
    
    func customSecureField(
        title: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        SecureField(title, text: text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .focused($focusedField, equals: field)
    }
}
