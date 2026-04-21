//
//  SettingRepositoryProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//

import Foundation

protocol SettingRepositoryProtocol {
    func logout() async throws -> LogoutModel
    func deleteAccount() async throws -> LogoutModel

}

final class SettingRepository: SettingRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
  
    func logout() async throws -> LogoutModel{
        return try await networkService.request(APIEndpoint.logout, responseType: LogoutModel.self)
    }
    
    func deleteAccount()async throws -> LogoutModel{
        return try await networkService.request(APIEndpoint.delete, responseType: LogoutModel.self)
    }
}
