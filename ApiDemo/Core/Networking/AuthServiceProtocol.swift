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
    let tokenStorage: TokenStorage
    
    init(session: URLSession = .shared, tokenStorage: TokenStorage) {
        self.session = session
        self.tokenStorage = tokenStorage
    }
    
    func refreshToken() async throws -> String {
        
        guard let url = URL(string: "http://localhost:3000/api/users/refresh-token") else {
            Logger.log("Invalid refresh token URL", level: .error)
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 🔐 Get refresh token
        guard let currentRefreshToken = tokenStorage.getRefreshToken() else {
            Logger.log("No refresh token found", level: .error)
            throw NetworkError.noRefreshToken
        }
        
        let requestBody = RefreshTokenRequest(refreshToken: currentRefreshToken)
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        // ⏱️ Start time
        let startTime = Date()
        
        // 🔥 Request Log
        Logger.log("🔄 Refresh Token Request: \(url.absoluteString)", level: .request)
        
        // ⚠️ Avoid logging full token in production
        Logger.log("RefreshToken: *****\(currentRefreshToken.suffix(5))", level: .info)
        
        Logger.prettyJSON(jsonData)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            let duration = Date().timeIntervalSince(startTime)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.log("Invalid response during refresh", level: .error)
                throw NetworkError.invalidResponse
            }
            
            // 🔥 Response Log
            Logger.log("Refresh Response Status: \(httpResponse.statusCode) (\(String(format: "%.2f", duration))s)", level: .info)
            Logger.prettyJSON(data)
            
            guard httpResponse.statusCode == 200 else {
                Logger.log("Token refresh failed with status \(httpResponse.statusCode)", level: .error)
                throw NetworkError.tokenRefreshFailed
            }
            
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            
            // 💾 Save new token
            tokenStorage.saveAccessToken(tokenResponse.accessToken)
            
            Logger.log("✅ Token refreshed successfully", level: .success)
            
            return tokenResponse.accessToken
            
        } catch let error as URLError {
            Logger.log("URLError during refresh: \(error.localizedDescription)", level: .error)
            throw NetworkError.unknown(error)
            
        } catch {
            Logger.log("Unknown error during refresh: \(error.localizedDescription)", level: .error)
            throw NetworkError.tokenRefreshFailed
        }
    }
}
struct TokenResponse: Decodable {
    let accessToken: String
}


struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}
