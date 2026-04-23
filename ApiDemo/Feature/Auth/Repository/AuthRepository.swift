//
//  AuthRepository.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import Foundation
protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> ApiResponse<AuthResponse>
    func signUp(name: String,userName: String, email: String, password: String) async throws -> ApiResponse<AuthResponse>
    func checkUserName(username: String) async throws -> UserNameCheck
    func forgotPassword(email: String) async throws -> ResetPassword
    func resetPassword(token: String, password: String) async throws -> ResetPassword



//    func updateUser(id: Int, name: String, email: String) async throws -> User
//    func deleteUser(id: Int) async throws
}

final class AuthRepository: AuthRepositoryProtocol {

    
    
    
   
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func signUp(name: String, userName: String ,email: String, password: String) async throws -> ApiResponse<AuthResponse> {
        let response = try await networkService.request(
            APIEndpoint.signUp(name: name, userName: userName, email: email, password: password),
            responseType: ApiResponse<AuthResponse>.self
        )
        
        return response
    }
    func login(email: String, password: String) async throws -> ApiResponse<AuthResponse> {
        let response = try await networkService.request(
            APIEndpoint.login(email: email, password: password),
            responseType: ApiResponse<AuthResponse>.self
        )
        return response
    }
    func checkUserName(username: String) async throws -> UserNameCheck {
        let response = try await networkService.request(
            APIEndpoint.checkUsername(userName: username),
            responseType: UserNameCheck.self
        )
        return response
    }
    func forgotPassword(email: String) async throws -> ResetPassword {
        let response = try await networkService.request(
            APIEndpoint.forgotPassword(email: email),
            responseType: ResetPassword.self
        )
        return response
    }
    
    func resetPassword(token: String, password: String) async throws -> ResetPassword {
        let response = try await networkService.request(
            APIEndpoint.resetPassword(token: token, password: password),
            responseType: ResetPassword.self
        )
        return response
    }
}
