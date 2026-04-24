//
//  ApiDemoApp.swift
//  ApiDemo
//
//  Created by ios-22 on 11/03/26.
//


import SwiftUI

@main
struct ApiDemoApp: App {
    // @Observable objects are injected via .environment(), not @StateObject
    private var session = SessionManager.shared
    private var nav     = NavigationManager.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(session)   // read anywhere with @Environment(SessionManager.self)
                .environment(nav)       // read anywhere with @Environment(NavigationManager.self)
                .onOpenURL { url in
                    nav.handleDeepLink(url)
                }
        }
    }
}

struct AppRootView: View {
    @Environment(SessionManager.self)    private var session
    @Environment(NavigationManager.self) private var nav

    var body: some View {
        if session.isLoggedIn {
            MainTabView()
                            // When the user logs out, reset all tab stacks so
                            // the next login starts fresh.
                            .onChange(of: session.isLoggedIn) { _, loggedIn in
                                if !loggedIn { nav.resetAllTabs() }
                            }
        } else {
            AuthFlowView()
                // Reset auth path when returning to the auth flow
                // (e.g. after logout) so Login is always the first screen.
                .onChange(of: session.isLoggedIn) { _, loggedIn in
                    if !loggedIn { nav.popToLogin() }
                }
        }
    }
}
