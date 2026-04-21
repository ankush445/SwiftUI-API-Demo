import Foundation
import Observation
@Observable
final class SessionManager {
    
    static let shared = SessionManager()
    
    private(set) var isLoggedIn: Bool = false
    private(set) var user: User?
    
    private let tokenStorage: TokenStorage
    private let userManager: UserManager
    
    // MARK: - Init
    
    private init(
        tokenStorage: TokenStorage = KeychainTokenStorage(),
        userManager: UserManager = .shared
    ) {
        self.tokenStorage = tokenStorage
        self.userManager = userManager
        
        self.user = userManager.getUser()
        self.isLoggedIn = userManager.isLoggedIn() // ✅ FIXED
    }
    
    // MARK: - Public Methods
    
    func login(response: AuthResponse) {
        tokenStorage.saveAccessToken(response.accessToken)
        tokenStorage.saveRefreshToken(response.refreshToken)
        
        userManager.saveUser(response.user) // also sets loggedIn = true
        
        self.user = response.user
        self.isLoggedIn = true
    }
    
    func logout() {
        tokenStorage.clearTokens()
        userManager.clear() // also sets loggedIn = false
        
        self.user = nil
        self.isLoggedIn = false
    }
}
