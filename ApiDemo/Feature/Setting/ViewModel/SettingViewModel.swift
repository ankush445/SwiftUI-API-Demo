//
//  SettingViewModel.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//

import SwiftUI
import Observation
import FancyToastKit
@Observable
final class SettingViewModel: ToastPresentable {
    
    var isLoading = false
    var toast: FancyToast?
    
    private let repository: SettingRepositoryProtocol
    private let session: SessionManager
    
    init(
        repository: SettingRepositoryProtocol,
        session: SessionManager
    ) {
        self.repository = repository
        self.session = session
    }
    
    // MARK: - Logout
    
    func logout() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response = try await repository.logout()
                
                await MainActor.run {
                    session.logout()
                    showSuccess(message: response.message)
                    HapticManager.trigger(.success)
                }
                
            } catch {
                await MainActor.run {
                    showError(error)
                    HapticManager.trigger(.error)
                }
            }
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response = try await repository.deleteAccount()
                
                await MainActor.run {
                    session.logout() // clear everything
                    showSuccess(message: response.message)
                    HapticManager.trigger(.success)
                }
                
            } catch {
                await MainActor.run {
                    showError(error)
                    HapticManager.trigger(.error)
                }
            }
        }
    }
}
