//
//  SettingsView.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import SwiftUI
import FancyToastKit
import SwiftUI_Loader
struct SettingsView: View {
    
    @Bindable var session: SessionManager
    @State private var vm: SettingViewModel
    
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    
    init(viewModel: SettingViewModel, session: SessionManager) {
        _vm = State(wrappedValue: viewModel)
        self.session = session
    }
    
    var body: some View {
        List {
            
            // 👤 Profile Section
            Section {
                VStack(spacing: 10) {
                    if let user = session.user {
                        
                        ZStack {
                            Circle()
                                .fill(dynamicColor(for: user.name))
                                .frame(width: 80, height: 80)
                            
                            Text(user.name.prefix(1))
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        
                        Text(user.name)
                            .font(.headline)
                        
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // ⚙️ Options
            Section("Account") {
                NavigationLink("My Posts") { Text("My Posts") }
                NavigationLink("Edit Profile") { Text("Edit Profile") }
                NavigationLink("Terms & Conditions") { Text("Terms") }
                NavigationLink("Privacy Policy") { Text("Privacy") }
            }
            
            // 🚨 Danger Zone
            Section("Danger Zone") {
                
                Button("Delete Account", role: .destructive) {
                    showDeleteAlert = true
                }
                
                Button("Logout", role: .destructive) {
                    showLogoutAlert = true
                }
            }
        }
        .navigationTitle("Settings")
        
        // 🔔 Logout Alert
        .alert("Logout?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                vm.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        
        // 🔔 Delete Alert
        .alert("Delete Account?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                vm.deleteAccount()
            }
        } message: {
            Text("This action cannot be undone.")
        }
          .toastView(toast: $vm.toast)
        .loadingIndicator(isLoading: vm.isLoading)
        
        
        
    }
}

// MARK: - Helper

private extension SettingsView {
    
    func dynamicColor(for name: String) -> Color {
        let hash = abs(name.hashValue)
        let hue = Double(hash % 256) / 255.0
        return Color(hue: hue, saturation: 0.6, brightness: 0.8)
    }
}
