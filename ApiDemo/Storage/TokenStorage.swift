import Foundation

protocol TokenStorage {
    func getAccessToken() -> String?
    func saveAccessToken(_ token: String)
    func getRefreshToken() -> String?
    func saveRefreshToken(_ token: String)
    func clearTokens()
}

import Foundation
import Security

final class KeychainTokenStorage: TokenStorage {
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    // MARK: - Public Methods
    
    func getAccessToken() -> String? {
        read(key: accessTokenKey)
    }
    
    func saveAccessToken(_ token: String) {
        save(key: accessTokenKey, value: token)
    }
    
    func getRefreshToken() -> String? {
        read(key: refreshTokenKey)
    }
    
    func saveRefreshToken(_ token: String) {
        save(key: refreshTokenKey, value: token)
    }
    
    func clearTokens() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }
}

// MARK: - Private Keychain Helpers

private extension KeychainTokenStorage {
    
    func save(key: String, value: String) {
        let data = Data(value.utf8)
        
        // Delete existing item first
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
