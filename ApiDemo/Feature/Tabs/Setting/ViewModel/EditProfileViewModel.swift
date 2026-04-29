//
//  EditProfileViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 29/04/26.
//

import SwiftUI
import Observation

@Observable
final class EditProfileViewModel: ToastPresentable {
    
    private let repository: EditProfileRepositoryProtocol
    
    var toast: FancyToast?
    var isLoading = false
    
    // Form Fields
    var name: String = ""
    var username: String = ""
    var bio: String = ""
    var website: String = ""
    var profileImage: String?
    
    // Password Change
//    var oldPassword: String = ""
//    var newPassword: String = ""
//    var confirmPassword: String = ""
    
    init(repository: EditProfileRepositoryProtocol,session: SessionManager) {
        self.repository = repository
        
        if let user = session.getUser() {
            initializeWithUser(user)
        }
    }
    
    // MARK: - Initialize with current user data
    func initializeWithUser(_ user: User) {
        self.name = user.name
        self.username = user.username
        self.bio = user.bio ?? ""
        self.website = user.website ?? ""
        self.profileImage = user.profileImage
    }
    
    // MARK: - Validation
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        username.count >= 3 &&
        bio.count <= 150
    }
    
//    var isPasswordValid: Bool {
//        !oldPassword.isEmpty &&
//        !newPassword.isEmpty &&
//        newPassword == confirmPassword &&
//        newPassword.count >= 6
//    }
    
    // MARK: - Update Profile
    @MainActor
    func updateProfile() async {
        guard isFormValid else {
            showError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please fill all required fields correctly"]))
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let request = EditProfileRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            username: username.trimmingCharacters(in: .whitespaces),
            bio: bio.trimmingCharacters(in: .whitespaces),
            website: website.isEmpty ? nil : website,
            profileImage: profileImage
        )
        
        do {
            let response = try await repository.updateProfile(request: request)
            await MainActor.run {
                showSuccess(message: response.message ?? "Profile updated successfully")
            }
        } catch {
            await MainActor.run {
                showError(error)
            }
        }
    }
    
    // MARK: - Change Password
//    @MainActor
//    func changePassword() async {
//        guard isPasswordValid else {
//            showError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Passwords don't match or are too short"]))
//            return
//        }
//        
//        guard !isLoading else { return }
//        
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let response = try await repository.changePassword(
//                oldPassword: oldPassword,
//                newPassword: newPassword
//            )
//            await MainActor.run {
//                showSuccess(message: response.message ?? "Password changed successfully")
//                // Clear password fields
//                oldPassword = ""
//                newPassword = ""
//                confirmPassword = ""
//            }
//        } catch {
//            await MainActor.run {
//                showError(error)
//            }
//        }
//    }
}
