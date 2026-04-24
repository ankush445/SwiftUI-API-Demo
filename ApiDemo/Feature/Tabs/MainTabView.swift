import SwiftUI

// MARK: - MainTabView

struct MainTabView: View {
    @Environment(SessionManager.self)    private var session
    @Environment(NavigationManager.self) private var nav

    var body: some View {
        @Bindable var nav = nav

        ZStack(alignment: .bottom) {

            // ── Page Content ──────────────────────────────────
            TabView(selection: $nav.selectedTab) {

                NavigationStack(path: $nav.homePath) {
                    HomeView(
                        viewModel: HomeViewModel(repository: AppDI.shared.postRepository),
                        session: session
                    )
                    .navigationDestination(for: HomeRoute.self) { route in
                        
                        switch route {
                        case .postDetail(let id):
                           Text("Post")
                        case .userProfile(let id):                           Text("Post")

                        case .comments(let id):                               Text("Post")

                        }
                    }
                }
                .tag(AppTab.home)

                NavigationStack(path: $nav.searchPath) {
//                    SearchView()
//                        .navigationDestination(for: SearchRoute.self) { route in
//                            switch route {
//                            case .searchResults(let q): SearchResultsView(query: q)
//                            case .userProfile(let id):  UserProfileView(userID: id)
//                            case .postDetail(let id):   PostDetailView(postID: id)
//                            }
//                        }
                }
                .tag(AppTab.search)

                // Placeholder — intercepted by onChange below
                Color.clear.tag(AppTab.createPost)

                NavigationStack(path: $nav.messagesPath) {
//                    MessagesView()
//                        .navigationDestination(for: MessagesRoute.self) { route in
//                            switch route {
//                            case .conversation(let id): ConversationView(userID: id)
//                            case .newMessage:           NewMessageView()
//                            }
//                        }
                }
                .tag(AppTab.messages)

                NavigationStack(path: $nav.profilePath) {
                    SettingsView(viewModel: SettingViewModel(repository: AppDI.shared.settingRepository, session: session), session: session)
//                        .navigationDestination(for: ProfileRoute.self) { route in
//                            switch route {
//                            case .editProfile: EditProfileView()
//                            case .settings:    SettingsView()
//                            case .followers:   FollowersView()
//                            case .following:   FollowingView()
//                            }
//                        }

                }
                .tag(AppTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // hides default system tab bar
            .ignoresSafeArea(edges: .bottom)

            // ── Custom Tab Bar ────────────────────────────────
            CustomTabBar(
                selectedTab: Binding(
                    get: { nav.selectedTab },
                    set: { nav.switchTab(to: $0) }
                )
            )
        }
        .sheet(item: $nav.activeSheet) { sheet in
//            switch sheet {
//            case .createPost:
//                CreatePostSheet()
//            case .imagePicker: ImagePickerSheet()
//            }
        }
        .fullScreenCover(item: $nav.activeFullScreen) { cover in
//            switch cover {
//            case .camera: CameraView()
//            }
        }
        .onChange(of: nav.selectedTab) { _, newTab in
            if newTab == .createPost {
                nav.selectedTab = .home
                nav.presentSheet(.createPost)
            }
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    private let tabs: [AppTab] = [.home, .search, .createPost, .messages, .profile]

    var body: some View {
        ZStack(alignment: .top) {
            // Bar background
            Color.appSecondaryBackground.ignoresSafeArea()

            // Icons row — sits in the bar, center button overflows upward
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
            .padding(.bottom, 0)
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
        case .search:   return "magnifyingglass"
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
                // Faint outer ring
                Circle()
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1.5)
                    .frame(width: 54, height: 54)

                // Indigo filled circle
                Circle()
                    .fill(
                        Color.buttonBackground
                    )
                    .frame(width: 50, height: 50)

                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            // Raise above the bar
            .offset(y: -15)
            .frame(maxWidth: .infinity, minHeight: 30)
            .contentShape(
                Circle()
                    .size(width: 54, height: 54)
                    .offset(x: 0, y: -15)  // match hit area to visual position
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
