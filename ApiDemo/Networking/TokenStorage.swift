import Foundation

protocol TokenStorage {
    func getAccessToken() -> String?
    func saveAccessToken(_ token: String)
    func clearTokens()
}

final class UserDefaultsTokenStorage: TokenStorage {
    
    private let userDefaults: UserDefaults
    private let accessTokenKey = "accessToken"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getAccessToken() -> String? {
        userDefaults.string(forKey: accessTokenKey)
    }
    
    func saveAccessToken(_ token: String) {
        userDefaults.set(token, forKey: accessTokenKey)
    }
    
    func clearTokens() {
        userDefaults.removeObject(forKey: accessTokenKey)
    }
}
