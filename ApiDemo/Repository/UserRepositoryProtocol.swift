//
//  UserRepositoryProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 11/03/26.
//

import Foundation
protocol UserRepositoryProtocol {
    func getUsers() async throws -> [User]
    func getUser(id: Int) async throws -> User
    func createUser(name: String, email: String) async throws -> User
    func updateUser(id: Int, name: String, email: String) async throws -> User
    func deleteUser(id: Int) async throws
}

final class UserRepository: UserRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getUsers() async throws -> [User] {
        try await networkService.request(
            APIEndpoint.getUsers,
            responseType: [User].self
        )
    }

    func getUser(id: Int) async throws -> User {
        try await networkService.request(
            APIEndpoint.getUser(id: id),
            responseType: User.self
        )
    }

    func createUser(name: String, email: String) async throws -> User {
        try await networkService.request(
            APIEndpoint.createUser(name: name, email: email),
            responseType: User.self
        )
    }

    func updateUser(id: Int, name: String, email: String) async throws -> User {
        try await networkService.request(
            APIEndpoint.updateUser(id: id, name: name, email: email),
            responseType: User.self
        )
    }

    func deleteUser(id: Int) async throws {
        
    }
}
