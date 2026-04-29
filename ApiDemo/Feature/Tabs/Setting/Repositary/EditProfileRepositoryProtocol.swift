//
//  EditProfileRepositoryProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 29/04/26.
//

import Foundation

protocol EditProfileRepositoryProtocol {
    func updateProfile(request: EditProfileRequest) async throws -> EditProfileResponse
    func changePassword(oldPassword: String, newPassword: String) async throws -> EditProfileResponse
}

final class EditProfileRepository: EditProfileRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func updateProfile(request: EditProfileRequest) async throws -> EditProfileResponse {
        return try await networkService.request(
            APIEndpoint.updateProfile(request: request),
            responseType: EditProfileResponse.self
        )
    }
    
    func changePassword(oldPassword: String, newPassword: String) async throws -> EditProfileResponse {
        return try await networkService.request(
            APIEndpoint.changePassword(oldPassword: oldPassword, newPassword: newPassword),
            responseType: EditProfileResponse.self
        )
    }
}
