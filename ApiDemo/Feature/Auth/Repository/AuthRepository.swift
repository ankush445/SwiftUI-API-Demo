//
//  AuthRepository.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import Foundation
protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> ApiResponse<AuthResponse>
    func signUp(name: String, email: String, password: String) async throws -> ApiResponse<AuthResponse>
//    func updateUser(id: Int, name: String, email: String) async throws -> User
//    func deleteUser(id: Int) async throws
}

final class AuthRepository: AuthRepositoryProtocol {
   
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func signUp(name: String, email: String, password: String) async throws -> ApiResponse<AuthResponse> {
        let response = try await networkService.request(
            APIEndpoint.signUp(name: name, email: email, password: password),
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
}
