//
//  UserDefaultStorage.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//
import Foundation
final class UserManager {
    static let shared = UserManager()

    private let userKey = "loggedInUser"
    private let loginKey = "isLoggedIn"

    // MARK: - Login State
    
    func setLoggedIn(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: loginKey)
    }
    
    func isLoggedIn() -> Bool {
        UserDefaults.standard.bool(forKey: loginKey)
    }
    
    func saveUser(_ user: User) {
        let data = try? JSONEncoder().encode(user)
        UserDefaults.standard.set(data, forKey: userKey)
        setLoggedIn(true)
    }

    func getUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    // MARK: - Clear
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: userKey)
        setLoggedIn(false)
    }
}
