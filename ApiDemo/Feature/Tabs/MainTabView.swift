import SwiftUI
import UIKit

// MARK: - MainTabView

struct MainTabView: View {
    @Environment(SessionManager.self)    private var session
    @Environment(NavigationManager.self) private var nav
    @State private var isKeyboardVisible = false

    var body: some View {
        @Bindable var nav = nav

        ZStack(alignment: .bottom) {

            TabView(selection: $nav.selectedTab) {

                // ── Home ──────────────────────────────────────
                // ProfileView and FollowListView are declared HERE
                // inside the Home stack. They are NOT routed through
                // ProfileRoute, so they never touch nav.profilePath.
                NavigationStack(path: $nav.homePath) {
                    HomeView(
                        viewModel: HomeViewModel(repository: AppDI.shared.postRepository),
                        session: session
                    )
                    .navigationDestination(for: HomeRoute.self) { route in
                        switch route {
                        case .userProfile(let userID):
                            // ✅ Reuses ProfileView but stays on Home stack
                            ProfileView(
                                viewModel: ProfileViewModel(
                                    repository: AppDI.shared.profileRepository,
                                    userId: userID
                                )
                            )

                        case .followers(let userId, let username, let tab):
                            FollowListView(
                                viewModel: FollowListViewModel(
                                    repository: AppDI.shared.followersRepository,
                                    userId: userId,
                                    username: username,
                                    selectedTab: tab == 0 ? .followers : .following
                                )
                            )
                        }
                    }
                }
                .tag(AppTab.home)

                // ── Friends ───────────────────────────────────
                NavigationStack(path: $nav.friendPath) {
                    FriendView(
                        viewModel: FriendViewModel(repository: AppDI.shared.friendRepository)
                    )
                    .navigationDestination(for: FriendRoute.self) { route in
                        switch route {
                        case .friendRequest:
                            FriendRequestView(
                                viewModel: FriendViewModel(repository: AppDI.shared.friendRepository)
                            )

                        case .userProfile(let userID):
                            // ✅ Same ProfileView, but lives on the Friend stack
                            ProfileView(
                                viewModel: ProfileViewModel(
                                    repository: AppDI.shared.profileRepository,
                                    userId: userID
                                )
                            )

                        case .followers(let userId, let username, let tab):
                            FollowListView(
                                viewModel: FollowListViewModel(
                                    repository: AppDI.shared.followersRepository,
                                    userId: userId,
                                    username: username,
                                    selectedTab: tab == 0 ? .followers : .following
                                )
                            )
                        }
                    }
                }
                .tag(AppTab.friends)

                // ── Create Post (sheet) ───────────────────────
                Color.clear
                    .tag(AppTab.createPost)

                // ── Messages ──────────────────────────────────
                NavigationStack(path: $nav.messagesPath) {
                    // Add MessagesView here when ready
//                    EmptyView()
//                        .navigationDestination(for: MessagesRoute.self) { route in
//                            switch route {
//                            case .conversation(let id): ConversationView(userID: id)
//                            case .newMessage:           NewMessageView()
//                            }
//                        }
                }
                .tag(AppTab.messages)

                // ── Profile (own tab) ─────────────────────────
                // This is the ONLY place that uses nav.profilePath.
                // Pushes from Home/Friends never reach this stack.
                NavigationStack(path: $nav.profilePath) {
                    ProfileView(
                        viewModel: ProfileViewModel(
                            repository: AppDI.shared.profileRepository,
                            userId: session.user?.id ?? ""
                        )
                    )
                    .navigationDestination(for: ProfileRoute.self) { route in
                        switch route {
                        case .followers(let userId, let username, let tab):
                            FollowListView(
                                viewModel: FollowListViewModel(
                                    repository: AppDI.shared.followersRepository,
                                    userId: userId,
                                    username: username,
                                    selectedTab: tab == 0 ? .followers : .following
                                )
                            )
                        }
                    }
                }
                .tag(AppTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            // ── Custom Tab Bar ────────────────────────────────
            if !isKeyboardVisible {
                CustomTabBar(
                    selectedTab: Binding(
                        get: { nav.selectedTab },
                        set: { nav.switchTab(to: $0) }
                    )
                )
            }
        }
        .sheet(item: $nav.activeSheet) { sheet in
            switch sheet {
            case .createPost:  EmptyView() // replace with CreatePostView()
            case .imagePicker: EmptyView() // replace with ImagePickerView()
            }
        }
        .fullScreenCover(item: $nav.activeFullScreen) { cover in
            switch cover {
            case .camera: EmptyView() // replace with CameraView()
            }
        }
        .onChange(of: nav.selectedTab) { _, newTab in
            if newTab == .createPost {
                nav.selectedTab = .home
                nav.presentSheet(.createPost)
            }
        }
        .preferredColorScheme(nil)
        .onAppear {
            // Set status bar background color
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor(Color.appSecondaryBackground)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    private let tabs: [AppTab] = [.home, .friends, .createPost, .messages, .profile]

    var body: some View {
        ZStack(alignment: .top) {
            Color.appSecondaryBackground
                .ignoresSafeArea(edges: .bottom)

            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    if tab == .createPost {
                        CreateTabButton(selectedTab: $selectedTab)
                    } else {
                        RegularTabButton(tab: tab, selectedTab: $selectedTab)
                    }
                }
            }
            .padding(.top, 10)
        }
        .frame(height: 49)
    }
}

// MARK: - Regular Tab Button

private struct RegularTabButton: View {
    let tab: AppTab
    @Binding var selectedTab: AppTab

    private var isSelected: Bool { selectedTab == tab }

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: icon)
                .font(.system(size: 21, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .buttonBackground : .textFieldIconBackground)
                .frame(maxWidth: .infinity, minHeight: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var icon: String {
        switch tab {
        case .home:     return isSelected ? "house.fill"    : "house"
        case .friends:  return isSelected ? "person.2.fill" : "person.2"
        case .messages: return isSelected ? "message.fill"  : "message"
        case .profile:  return isSelected ? "person.fill"   : "person"
        default:        return ""
        }
    }
}

// MARK: - Create (Center) Tab Button

private struct CreateTabButton: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        Button {
            selectedTab = .createPost
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1.5)
                    .frame(width: 54, height: 54)

                Circle()
                    .fill(Color.buttonBackground)
                    .frame(width: 50, height: 50)

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            .offset(y: -15)
            .frame(maxWidth: .infinity, minHeight: 30)
            .contentShape(
                Circle()
                    .size(width: 54, height: 54)
                    .offset(x: 0, y: -15)
            )
        }
        .buttonStyle(.plain)
    }
}
