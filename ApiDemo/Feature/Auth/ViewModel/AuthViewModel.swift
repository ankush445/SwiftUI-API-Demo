import Foundation
import FancyToastKit
import Observation
@Observable
final class AuthViewModel:ToastPresentable {
    
    private let repository: AuthRepositoryProtocol
    private let sessionManager: SessionManager
    var isLoginMode: Bool = true
    var email = ""
    var password = ""
    var confirmPassword = ""
    var name = ""
    var username = ""
    var isLoading = false
    var toast: FancyToast?
    
    enum UsernameState: Equatable {
        case idle
        case checking
        case available
        case taken
        case invalid(String) // 👈 NEW (for API validation message)
    }
    var usernameState: UsernameState = .idle
    private var usernameTask: Task<Void, Never>?
    
    init(
        repository: AuthRepositoryProtocol,
        sessionManager: SessionManager = .shared
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
    }
    
    // MARK: - Sign Up
    
    func createUser() async {
        guard valid() else {
            return
        }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResponse = try await repository.signUp(
                name: name,
                userName: username,
                email: email,
                password: password
            )
            
            // ✅ Centralized session handling
            sessionManager.login(response: authResponse.data)
            await MainActor.run {
                showSuccess(message: authResponse.message ?? "Account created successfully")
            }
            
        } catch {
            await MainActor.run {
                showError(error)
            }
            
        }
    }
    
    // MARK: - Login
    
    func loginUser() async {
        guard valid() else {
            return
        }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResponse = try await repository.login(
                email: email,
                password: password
            )
            
            // ✅ Centralized session handling
            sessionManager.login(response: authResponse.data)
            await MainActor.run {
                showSuccess(message: authResponse.message ?? "Login successful")
            }
        } catch {
            await MainActor.run {
                showError(error)
            }
        }
    }
    
    private func valid()-> Bool {
        guard isValidEmail(email: email) else {
            showError(message: AppStrings.invalidEmail)
            return false
        }
        guard isValidPassword(password: password) else {
            showError(message: AppStrings.invalidPassword)
            return false
        }
        
        if !isLoginMode {
            guard isValidName(name: name) else {
                showError(message: AppStrings.invalidName)
                return false
            }
        }
        return true
    }
    func checkUsernameAvailabilityDebounced() {
        guard username.count >= 3 else {
            usernameState = .idle
            return
        }
        
        let regex = "^[a-zA-Z0-9_]+$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)

        guard isValid else {
            usernameState = .invalid(AppStrings.usernameInvalidFormat)
            return
        }
        // cancel previous task
        usernameTask?.cancel()
        
        // empty case
        guard !username.isEmpty else {
            usernameState = .idle
            return
        }
        
        usernameState = .checking
        
        usernameTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // ⏱ 0.5 sec debounce
            
            // if cancelled, stop
            if Task.isCancelled { return }
            
            await checkUsernameAvailable()
        }
    }
    private func checkUsernameAvailable() async {
        do {
            let response = try await repository.checkUserName(username: username)
            
            await MainActor.run {
                
                // ❌ Case: Validation error (like your JSON)
                if response.success == false {
                    usernameState = .invalid(response.message ?? "")
                    return
                }
                
                // ✅ Case: Available / Taken
                if response.available == true {
                    usernameState = .available
                } else {
                    usernameState = .taken
                }
            }
            
        } catch {
            await MainActor.run {
                usernameState = .invalid("Something went wrong")
            }
        }
    }
    
    var isAuthButtonDisabled: Bool {
        
        // Common validations
        if email.isEmpty || password.isEmpty {
            return true
        }
        
        // Signup-specific validations
        if !isLoginMode {
               if name.isEmpty {
                   return true
               }
               
               if case .available = usernameState {
                   // ok
               } else {
                   return true
               }
           }
        
        return false
    }
    func isPasswordMatching() -> Bool {
        return password == confirmPassword
    }
    func sendResetEmail() async -> Bool {
        guard isValidEmail(email: email) else {
            showError(message: AppStrings.invalidEmail)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.forgotPassword(email: email)
            
            if let token = response.resetToken {
                UserManager.shared.saveResetToken(token)
            }
            
//            await MainActor.run {
//                showSuccess(message: response.message ?? "")
//            }
            
            return true
        } catch {
            await MainActor.run {
                showError(error)
            }
            return false
        }
    }
    
    func resetPassword() async -> Bool {
        
        guard isValidPassword(password: password) else {
            showError(message: AppStrings.invalidPassword)
            return false
        }
        
        guard isPasswordMatching() else {
            showError(message: AppStrings.passwordNotMatch)
            return false
        }
        
        guard let token = UserManager.shared.getResetToken() else {
            showError(message: AppStrings.somethingWentWrong)
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await repository.resetPassword(
                token: token,
                password: password
            )
            
            await MainActor.run {
                showSuccess(message: response.message ?? "")
            }
            return true
            
        } catch {
            await MainActor.run {
                showError(error)
            }
            return false

        }
    }
}
extension AuthViewModel {
    
    func resetFields() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        username = ""
        toast = nil
    }
}
