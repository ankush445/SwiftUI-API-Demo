import Foundation
import FancyToastKit
import Observation
@Observable
final class AuthViewModel:ToastPresentable {
    
    private let repository: AuthRepositoryProtocol
    private let sessionManager: SessionManager
    var email = ""
    var password = ""
    var name = ""
    var isLoading = false
    var toast: FancyToast?
    
    init(
        repository: AuthRepositoryProtocol,
        sessionManager: SessionManager = .shared
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
    }
    
    // MARK: - Sign Up
    
    func createUser(name: String, email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResponse = try await repository.signUp(
                name: name,
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
    
    func loginUser(email: String, password: String) async {
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
}
extension AuthViewModel {
    
    func resetFields() {
        name = ""
        email = ""
        password = ""
        toast = nil
    }
}
