import SwiftUI

struct SettingsView: View {
    
    @Environment(NavigationManager.self) private var nav
    @Bindable var session: SessionManager
    @State private var vm: SettingViewModel
    
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    
    init(viewModel: SettingViewModel, session: SessionManager) {
        vm = viewModel
        self.session = session
    }
    
    var body: some View {
        VStack {
            headerView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    profileCardSection
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    
//                    Divider().padding(.vertical, 12)
//                    
//                    accountSettingsSection
                    
                  
                    
                    notificationsSection
                    
                    
                    aboutSection
                    
                    
                    dangerZoneSection
                    
                    Spacer()
                        .frame(height: 50)
                    
                }
                .background(Color.appBackground)
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.appBackground)
        .navigationBarBackButtonHidden()
        
        // 🔔 Logout Alert
        .alert(AppStrings.logoutTitle, isPresented: $showLogoutAlert) {
            Button(AppStrings.cancel, role: .cancel) {}
            Button(AppStrings.logout, role: .destructive) {
                vm.logout()
            }
        } message: {
            Text(AppStrings.logoutMessage)
        }
        
        // 🔔 Delete Alert
        .alert(AppStrings.deleteTitle, isPresented: $showDeleteAlert) {
            Button(AppStrings.cancel, role: .cancel) {}
            Button(AppStrings.deleteAccount, role: .destructive) {
                vm.deleteAccount()
            }
        } message: {
            Text(AppStrings.deleteMessage)
        }
        
        .toastView(toast: $vm.toast)
        .loadingIndicator(isLoading: vm.isLoading)
    }
}

// MARK: - Header
extension SettingsView {
    
    func headerView() -> some View {
        VStack(spacing: 6) {
            HStack {
                CustomBackButton(title: nil) {
                    nav.pop()
                }
                .frame(width: 44)
                
                Spacer()
                
                Text(AppStrings.settings)
                    .customFont(.semiBold, 18)
                
                Spacer()
                
                Color.clear.frame(width: 44)
            }
            .padding(.horizontal)
            .frame(height: 44)
        }
        .background(Color.appSecondaryBackground)
    }
}

// MARK: - Profile Card
extension SettingsView {
    
    var profileCardSection: some View {
        VStack {
            HStack(spacing: 12) {
                
                if let user = session.user {
                    
                    Text(user.name.prefix(1))
                        .customFont(.bold, 24)
                        .frame(width: 60, height: 60)
                        .background(dynamicColor(for: user.name))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .customFont(.semiBold, 16)
                        
                        Text("@\(user.username)")
                            .customFont(.regular, 13)
                            .foregroundStyle(.secondaryText)
                        
                        Text(user.email ?? "")
                            .customFont(.regular, 12)
                            .foregroundStyle(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondaryText)
                }
            }
            .padding(12)
            .background(Color.textFieldBackground)
            .cornerRadius(12)
            .onTapGesture {
                nav.pushProfile(ProfileRoute.editProfile)
            }
        }
    }
}

// MARK: - Account Section
extension SettingsView {
    
    var accountSettingsSection: some View {
        VStack(alignment: .leading) {
            
            Text(AppStrings.account)
                .customFont(.semiBold, 14)
                .foregroundStyle(.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            VStack(spacing: 0) {
                
                settingRow(
                    icon: "square.stack.fill",
                    title: AppStrings.myPosts,
                    subtitle: AppStrings.viewYourPosts,
                    action: {}
                )
                
                Divider().padding(.horizontal, 16)
                
                settingRow(
                    icon: "person.crop.circle.fill",
                    title: AppStrings.editProfile,
                    subtitle: AppStrings.updateYourInfo,
                    action: {
                        nav.pushProfile(ProfileRoute.editProfile)
                    }
                )
                
                Divider().padding(.horizontal, 16)
                
                settingRow(
                    icon: "bookmark.fill",
                    title: AppStrings.savedPosts,
                    subtitle: AppStrings.bookmarkedPosts,
                    action: {}
                )
            }
            .background(Color.textFieldBackground)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preferences
extension SettingsView {
    
    var notificationsSection: some View {
        VStack(alignment: .leading) {
            
            Text(AppStrings.preferences)
                .customFont(.semiBold, 14)
                .foregroundStyle(.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            VStack(spacing: 0) {
                
                settingRow(
                    icon: "bell.fill",
                    title: AppStrings.notifications,
                    subtitle: AppStrings.manageNotifications,
                    action: {}
                )
                
                Divider().padding(.horizontal, 16)
                
                settingRow(
                    icon: "lock.fill",
                    title: AppStrings.privacySecurity,
                    subtitle: AppStrings.controlProfileVisibility,
                    action: {}
                )
                
                Divider().padding(.horizontal, 16)
                
                settingRow(
                    icon: "xmark.circle.fill",
                    title: AppStrings.blockedUsers,
                    subtitle: AppStrings.manageBlockedAccounts,
                    action: {}
                )
            }
            .background(Color.textFieldBackground)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Support
extension SettingsView {
    
    var aboutSection: some View {
        VStack(alignment: .leading) {
            
            Text(AppStrings.support)
                .customFont(.semiBold, 14)
                .foregroundStyle(.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            VStack(spacing: 0) {
                
                settingRow(
                    icon: "questionmark.circle.fill",
                    title: AppStrings.helpCenter,
                    subtitle: AppStrings.getHelpSupport,
                    action: {}
                )
                
                Divider().padding(.horizontal, 16)
                
                settingRow(
                    icon: "doc.text.fill",
                    title: AppStrings.termsConditions,
                    subtitle: AppStrings.readTerms,
                    action: {}
                )
                
                Divider().padding(.horizontal, 16)
                
                settingRow(
                    icon: "shield.fill",
                    title: AppStrings.privacyPolicy,
                    subtitle: AppStrings.readPrivacyPolicy,
                    action: {}
                )
                
                Divider().padding(.horizontal, 16)
                
                settingRow(
                    icon: "info.circle.fill",
                    title: AppStrings.aboutApp,
                    subtitle: String(format: AppStrings.appVersion, "1.0.0"),
                    action: {}
                )
            }
            .background(Color.textFieldBackground)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Danger Zone
extension SettingsView {
    
    var dangerZoneSection: some View {
        VStack(alignment: .leading) {
            
            Text(AppStrings.dangerZone)
                .customFont(.semiBold, 14)
                .foregroundStyle(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            VStack(spacing: 0) {
                
                Button {
                    showDeleteAlert = true
                } label: {
                    dangerRow(
                        icon: "trash.fill",
                        title: AppStrings.deleteAccount,
                        subtitle: AppStrings.deleteAccountDesc
                    )
                }
                
                Divider().padding(.horizontal, 16)
                
                Button {
                    showLogoutAlert = true
                } label: {
                    dangerRow(
                        icon: "arrow.right.circle.fill",
                        title: AppStrings.logout,
                        subtitle: AppStrings.logoutDesc
                    )
                }
            }
            .background(Color.textFieldBackground)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Reusable Rows
extension SettingsView {
    
    func settingRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                
                Image(systemName: icon)
                    .foregroundColor(.buttonBackground)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .customFont(.medium, 14)
                        .foregroundStyle(.primaryText)
                    Text(subtitle)
                        .customFont(.regular, 12)
                        .foregroundStyle(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondaryText)
            }
            .padding(12)
        }
    }
    
    func dangerRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.red)
                Text(subtitle)
                    .customFont(.regular, 12)
                    .foregroundStyle(.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondaryText)
        }
        .padding(12)
    }
}
