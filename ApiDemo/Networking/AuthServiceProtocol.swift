//
//  AuthServiceProtocol.swift
//  ApiDemo
//
//  Created by ios-22 on 11/03/26.
//

import Foundation
protocol AuthServiceProtocol {
    func refreshToken() async throws -> String
}

final class AuthService: AuthServiceProtocol {
    
    private let session: URLSession
    private let tokenStorage: TokenStorage
    
    init(session: URLSession = .shared, tokenStorage: TokenStorage) {
        self.session = session
        self.tokenStorage = tokenStorage
    }
    
    func refreshToken() async throws -> String {
        
        guard let url = URL(string: "https://api.example.com/refresh-token") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.tokenRefreshFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        tokenStorage.saveAccessToken(tokenResponse.accessToken)
        
        return tokenResponse.accessToken
    }
}
struct TokenResponse: Decodable {
    let accessToken: String
}
