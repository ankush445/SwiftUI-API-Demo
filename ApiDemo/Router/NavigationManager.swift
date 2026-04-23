import SwiftUI

// MARK: - Auth Routes

enum AuthRoute: Hashable {
    case forgotPassword
    case resetPassword
}

// MARK: - Tab

enum AppTab: Int, CaseIterable {
    case home
    case search
    case createPost
    case messages
    case profile

    var title: String {
        switch self {
        case .home:       return "Home"
        case .search:     return "Search"
        case .createPost: return "Create"
        case .messages:   return "Messages"
        case .profile:    return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home:       return "house.fill"
        case .search:     return "magnifyingglass"
        case .createPost: return "plus.app.fill"
        case .messages:   return "message.fill"
        case .profile:    return "person.crop.circle.fill"
        }
    }
}

// MARK: - Per-Tab Routes

enum HomeRoute: Hashable {
    case postDetail(postID: String)
    case userProfile(userID: String)
    case comments(postID: String)
}

enum SearchRoute: Hashable {
    case searchResults(query: String)
    case userProfile(userID: String)
    case postDetail(postID: String)
}

enum MessagesRoute: Hashable {
    case conversation(userID: String)
    case newMessage
}

enum ProfileRoute: Hashable {
    case editProfile
    case settings
    case followers
    case following
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
// Mirrors your SessionManager pattern: @Observable singleton,
// injected via .environment(nav) and read with @Environment(NavigationManager.self).

@Observable
final class NavigationManager {

    static let shared = NavigationManager()
    private init() {}

    // MARK: Auth stack
    var authPath: NavigationPath = NavigationPath()

    // MARK: Active tab
    var selectedTab: AppTab = .home

    // MARK: Per-tab stacks
    var homePath:     NavigationPath = NavigationPath()
    var searchPath:   NavigationPath = NavigationPath()
    var messagesPath: NavigationPath = NavigationPath()
    var profilePath:  NavigationPath = NavigationPath()

    // MARK: Sheet / full screen
    var activeSheet:      AppSheet?      = nil
    var activeFullScreen: AppFullScreen? = nil

    // ─────────────────────────────────────────
    // MARK: Auth Actions
    // ─────────────────────────────────────────

    func showForgotPassword() {
        authPath.append(AuthRoute.forgotPassword)
    }

    func showResetPassword() {
        authPath.append(AuthRoute.resetPassword)
    }

    /// Pops entire auth stack back to Login.
    func popToLogin() {
        authPath = NavigationPath()
    }
    func authPop() {
        authPath.removeLast()
    }

    // ─────────────────────────────────────────
    // MARK: Tab Actions
    // ─────────────────────────────────────────

    /// Tapping the already-active tab pops it to root (Instagram / Twitter behaviour).
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
        case .search:     searchPath   = NavigationPath()
        case .messages:   messagesPath = NavigationPath()
        case .profile:    profilePath  = NavigationPath()
        case .createPost: break
        }
    }

    func resetAllTabs() {
        homePath     = NavigationPath()
        searchPath   = NavigationPath()
        messagesPath = NavigationPath()
        profilePath  = NavigationPath()
        selectedTab  = .home
    }

    // ─────────────────────────────────────────
    // MARK: Home
    // ─────────────────────────────────────────

    func pushHome(_ route: HomeRoute) {
        selectedTab = .home
        homePath.append(route)
    }

    // ─────────────────────────────────────────
    // MARK: Search
    // ─────────────────────────────────────────

    func pushSearch(_ route: SearchRoute) {
        selectedTab = .search
        searchPath.append(route)
    }

    // ─────────────────────────────────────────
    // MARK: Messages
    // ─────────────────────────────────────────

    func pushMessages(_ route: MessagesRoute) {
        selectedTab = .messages
        messagesPath.append(route)
    }

    // ─────────────────────────────────────────
    // MARK: Profile
    // ─────────────────────────────────────────

    func pushProfile(_ route: ProfileRoute) {
        selectedTab = .profile
        profilePath.append(route)
    }

    // ─────────────────────────────────────────
    // MARK: Sheet / Full Screen
    // ─────────────────────────────────────────

    func presentSheet(_ sheet: AppSheet) {
        activeSheet = sheet
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func presentFullScreen(_ cover: AppFullScreen) {
        activeFullScreen = cover
    }

    func dismissFullScreen() {
        activeFullScreen = nil
    }

    // ─────────────────────────────────────────
    // MARK: Deep Link
    // ─────────────────────────────────────────

    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else { return }

        switch host {
        case "post":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                pushHome(.postDetail(postID: id))
            }
        case "user":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                pushHome(.userProfile(userID: id))
            }
        case "messages":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                pushMessages(.conversation(userID: id))
            }
        default:
            break
        }
    }
}
