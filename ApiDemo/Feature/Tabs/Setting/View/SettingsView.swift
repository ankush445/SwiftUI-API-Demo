////
////  SettingsView.swift
////  ApiDemo
////
////  Created by ios-22 on 17/04/26.
////
//
//import SwiftUI
//struct SettingsView: View {
//    
//    @Bindable var session: SessionManager
//    @State private var vm: SettingViewModel
//    
//    @State private var showLogoutAlert = false
//    @State private var showDeleteAlert = false
//    
//    init(viewModel: SettingViewModel, session: SessionManager) {
//        _vm = State(wrappedValue: viewModel)
//        self.session = session
//    }
//    
//    var body: some View {
//        List {
//            
//            // 👤 Profile Section
//            Section {
//                VStack(spacing: 10) {
//                    if let user = session.user {
//                        
//                        ZStack {
//                            Circle()
//                                .fill(dynamicColor(for: user.name))
//                                .frame(width: 80, height: 80)
//                            
//                            Text(user.name.prefix(1))
//                                .font(.largeTitle)
//                                .foregroundColor(.white)
//                        }
//                        
//                        Text(user.name)
//                            .font(.headline)
//                        
//                        Text(user.email ?? "xyz@gmail.com")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//            }
//            
//            // ⚙️ Options
//            Section("Account") {
//                NavigationLink("My Posts") {
//                    if let user = session.user {
//                        UserPostView(viewModel: UserPostViewModel(repository: AppDI.shared.postRepository, userId: user.id), session: session)
//                    }else {
//                        Text("My Post")
//                    }
//                }
//                NavigationLink("Edit Profile") { Text("Edit Profile") }
//                NavigationLink("Terms & Conditions") { Text("Terms") }
//                NavigationLink("Privacy Policy") { Text("Privacy") }
//            }
//            
//            // 🚨 Danger Zone
//            Section("Danger Zone") {
//                
//                Button("Delete Account", role: .destructive) {
//                    showDeleteAlert = true
//                }
//                
//                Button("Logout", role: .destructive) {
//                    showLogoutAlert = true
//                }
//            }
//        }
//        .navigationTitle("Settings")
//        
//        // 🔔 Logout Alert
//        .alert("Logout?", isPresented: $showLogoutAlert) {
//            Button("Cancel", role: .cancel) {}
//            Button("Logout", role: .destructive) {
//                vm.logout()
//            }
//        } message: {
//            Text("Are you sure you want to logout?")
//        }
//        
//        // 🔔 Delete Alert
//        .alert("Delete Account?", isPresented: $showDeleteAlert) {
//            Button("Cancel", role: .cancel) {}
//            Button("Delete", role: .destructive) {
//                vm.deleteAccount()
//            }
//        } message: {
//            Text("This action cannot be undone.")
//        }
//          .toastView(toast: $vm.toast)
//        .loadingIndicator(isLoading: vm.isLoading)
//        
//        
//        
//    }
//}
//
