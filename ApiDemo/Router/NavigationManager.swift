import SwiftUI

// MARK: - Auth Routes

enum AuthRoute: Hashable {
    case forgotPassword
    case resetPassword
}

// MARK: - Tab

enum AppTab: Int, CaseIterable {
    case home
    case friends
    case createPost
    case messages
    case profile
}

// MARK: - Per-Tab Routes

enum HomeRoute: Hashable {
    case userProfile(userID: String)
    case followers(userId: String, username: String, selectedTab: Int)
}

enum FriendRoute: Hashable {
    case friendRequest
    case userProfile(userID: String)
    case followers(userId: String, username: String, selectedTab: Int)
}

enum MessagesRoute: Hashable {
    case conversation(userID: String)
    case newMessage
}

enum ProfileRoute: Hashable {
    case followers(userId: String, username: String, selectedTab: Int)
}

// MARK: - Sheet / Full Screen Cover

enum AppSheet: Identifiable {
    case createPost
    case imagePicker

    var id: String {
        switch self {
        case .createPost:  return "createPost"
        case .imagePicker: return "imagePicker"
        }
    }
}

enum AppFullScreen: Identifiable {
    case camera

    var id: String {
        switch self {
        case .camera: return "camera"
        }
    }
}

// MARK: - NavigationManager

@Observable
final class NavigationManager {

    static let shared = NavigationManager()
    private init() {}

    // MARK: Auth
    var authPath: NavigationPath = NavigationPath()

    // MARK: Active tab
    var selectedTab: AppTab = .home

    // MARK: Per-tab stacks
    var homePath:     NavigationPath = NavigationPath()
    var friendPath:   NavigationPath = NavigationPath()
    var messagesPath: NavigationPath = NavigationPath()
    var profilePath:  NavigationPath = NavigationPath()

    // MARK: Overlays
    var activeSheet:      AppSheet?      = nil
    var activeFullScreen: AppFullScreen? = nil

    // ─────────────────────────────────────────
    // MARK: Auth
    // ─────────────────────────────────────────

    func showForgotPassword() {
        authPath.append(AuthRoute.forgotPassword)
    }

    func showResetPassword() {
        authPath.append(AuthRoute.resetPassword)
    }

    func authPop() {
        guard !authPath.isEmpty else { return }
        authPath.removeLast()
    }

    func popToLogin() {
        authPath = NavigationPath()
    }

    // ─────────────────────────────────────────
    // MARK: Tab Switching
    // ─────────────────────────────────────────

    func switchTab(to tab: AppTab) {
        if selectedTab == tab {
            popToRoot(for: tab)
        } else {
            selectedTab = tab
        }
    }

    func popToRoot(for tab: AppTab) {
        switch tab {
        case .home:       homePath     = NavigationPath()
        case .friends:    friendPath   = NavigationPath()
        case .messages:   messagesPath = NavigationPath()
        case .profile:    profilePath  = NavigationPath()
        case .createPost: break
        }
    }

    func resetAllTabs() {
        homePath     = NavigationPath()
        friendPath   = NavigationPath()
        messagesPath = NavigationPath()
        profilePath  = NavigationPath()
        selectedTab  = .home
    }

    // ─────────────────────────────────────────
    // MARK: Safe Pop (fixes crash on empty path)
    // ─────────────────────────────────────────

    func pop() {
        switch selectedTab {
        case .home:
            guard !homePath.isEmpty else { return }
            homePath.removeLast()
        case .friends:
            guard !friendPath.isEmpty else { return }
            friendPath.removeLast()
        case .messages:
            guard !messagesPath.isEmpty else { return }
            messagesPath.removeLast()
        case .profile:
            guard !profilePath.isEmpty else { return }
            profilePath.removeLast()
        case .createPost:
            break
        }
    }

    // ─────────────────────────────────────────
    // MARK: Push — NO forced tab switching
    //
    // ⚠️ Key fix: pushHome / pushFriend / pushProfile
    // only mutate THEIR OWN path. They never touch
    // selectedTab. This prevents ProfileView or
    // FollowListView from hijacking the active tab
    // when reused across multiple tabs.
    // ─────────────────────────────────────────

    func pushHome(_ route: HomeRoute) {
        homePath.append(route)
    }

    func pushFriend(_ route: FriendRoute) {
        friendPath.append(route)
    }

    func pushMessages(_ route: MessagesRoute) {
        selectedTab = .messages   // messages are always a deliberate tab switch
        messagesPath.append(route)
    }

    func pushProfile(_ route: ProfileRoute) {
        // Only called from the Profile tab itself.
        // Other tabs push ProfileView via their own route enums.
        profilePath.append(route)
    }

    // ─────────────────────────────────────────
    // MARK: Cross-tab convenience
    // ─────────────────────────────────────────

    /// Push followers/following from ProfileView without knowing which tab is active.
    /// ProfileView calls this single method; the manager routes to the right stack.
    func pushFollowers(userId: String, username: String, selectedTab: Int) {
        switch self.selectedTab {
        case .home:
            homePath.append(HomeRoute.followers(userId: userId, username: username, selectedTab: selectedTab))
        case .friends:
            friendPath.append(FriendRoute.followers(userId: userId, username: username, selectedTab: selectedTab))
        case .profile:
            profilePath.append(ProfileRoute.followers(userId: userId, username: username, selectedTab: selectedTab))
        default:
            break
        }
    }

    /// Push a user profile from any tab without knowing the current context.
    func pushUserProfile(userID: String) {
        switch self.selectedTab {
        case .home:
            homePath.append(HomeRoute.userProfile(userID: userID))
        case .friends:
            friendPath.append(FriendRoute.userProfile(userID: userID))
        default:
            break
        }
    }

    // ─────────────────────────────────────────
    // MARK: Overlays
    // ─────────────────────────────────────────

    func presentSheet(_ sheet: AppSheet) { activeSheet = sheet }
    func dismissSheet()                  { activeSheet = nil   }

    func presentFullScreen(_ cover: AppFullScreen) { activeFullScreen = cover }
    func dismissFullScreen()                       { activeFullScreen = nil   }

    func handleDeepLink(_ url: URL) { }
}
