//
//  EditProfileView.swift
//  ApiDemo
//
//  Created by ios-22 on 29/04/26.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(NavigationManager.self) private var nav
    @Environment(SessionManager.self) private var session
    
    @State private var vm: EditProfileViewModel
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    init(viewModel: EditProfileViewModel) {
        vm =  viewModel
    }
    
    
    var body: some View {
        
        VStack {
            
            headerView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 👤 Profile Picture Section
                    profilePictureSection
                        .padding(.horizontal, 16)
                    
                    
                    // 📝 Basic Info Section
                    basicInfoSection
                        .padding(.horizontal, 16)
                    
//                    // 🔐 Password Section
//                    passwordSection
//                    
                    // 💾 Save Button
                    saveButton
                    
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.vertical, 20)
                .background(Color.appBackground)

            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
        .background(Color.appBackground)
        .navigationBarBackButtonHidden()
        .toastView(toast: $vm.toast)
        .loadingIndicator(isLoading: vm.isLoading)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
//            if let image = newImage {
//                // Convert image to base64 or handle upload
//                vm.profileImage = "image_data"
//            }
        }
    }
    
    @ViewBuilder
    func headerView() -> some View {
        VStack(spacing: 6) {   // 🔥 reduced spacing
            
            // Top bar
            HStack {
                CustomBackButton(title: nil) {
                    nav.pop()
                }
                .frame(width: 44, alignment: .leading)
                
                Spacer()
                
                Text(AppStrings.editProfile)
                    .customFont(.semiBold, 18)
                    .foregroundStyle(.primaryText)// slightly smaller
                
                Spacer()
                
                Color.clear.frame(width: 44)
            }
            .padding(.horizontal)
            .frame(height: 44) // 🔥 fixed height
           
        }
        .background(Color.appSecondaryBackground)
    }
    
    // MARK: - Profile Picture Section
    var profilePictureSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                // Current Profile Picture
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Text(session.user?.name.prefix(1) ?? "A")
                        .customFont(.bold, 32)
                        .frame(width: 100, height: 100)
                        .background(dynamicColor(for: session.user?.name ?? "A"))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                // Edit Button
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.buttonBackground)
                        .clipShape(Circle())
                }
            }
            
            Text(AppStrings.tapToChangeProfile)
                .customFont(.regular, 12)
                .foregroundStyle(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    // MARK: - Basic Info Section
    var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Name Field
            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.fullName)
                    .customFont(.semiBold, 14)
                    .foregroundStyle(Color.textFieldIconBackground)
                inputField(
                    icon: "person",
                    placeholder: AppStrings.email,
                    text: $vm.name
                )
            }
            
            // Username Field
            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.username)
                    .customFont(.semiBold, 14)
                    .foregroundStyle(Color.textFieldIconBackground)
                inputField(
                    icon: "at",
                    placeholder: AppStrings.username,
                    text: $vm.name
                )
                if vm.username.count < 3 && !vm.username.isEmpty {
                    Text("Username must be at least 3 characters")
                        .customFont(.regular, 12)
                        .foregroundColor(.red)
                }
            }
            
            // Bio Field
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(AppStrings.bio)
                        .customFont(.semiBold, 14)
                        .foregroundStyle(Color.textFieldIconBackground)
                    
                    Spacer()
                    
                    Text("\(vm.bio.count)/150")
                        .customFont(.regular, 12)
                        .foregroundStyle(Color.textFieldIconBackground)
                }
                
                TextEditor(text: $vm.bio)
                    .customFont(.regular, 14)
                    .frame(height: 100)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(Color.textFieldBackground)
                    .cornerRadius(10)
                    .scrollContentBackground(.hidden)
            }
            
            // Website Field
            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.website)
                    .customFont(.semiBold, 14)
                    .foregroundStyle(Color.textFieldIconBackground)

                TextField("https://example.com", text: $vm.website)
                    .customFont(.regular, 14)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.textFieldBackground)
                    .cornerRadius(10)
            }
        }
    }
    
//    // MARK: - Password Section
//    var passwordSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            
//            Text(AppStrings.changePassword)
//                .customFont(.semiBold, 16)
//                .foregroundStyle(.primaryText)
//            
//            // Old Password
//            VStack(alignment: .leading, spacing: 6) {
//                Text(AppStrings.currentPassword)
//                    .customFont(.semiBold, 14)
//                    .foregroundStyle(Color.textFieldIconBackground)
//
//                SecureInputField(icon: "lock", placeholder: AppStrings.enterCurrentPassword, text: $vm.oldPassword)
//            }
//            
//            
//            // New Password
//            VStack(alignment: .leading, spacing: 6) {
//                Text(AppStrings.newPassword)
//                    .customFont(.semiBold, 14)
//                    .foregroundStyle(Color.textFieldIconBackground)
//
//                SecureInputField(icon: "lock", placeholder: AppStrings.enterNewPassword, text: $vm.newPassword)
//            }
//            // Confirm Password
//            VStack(alignment: .leading, spacing: 6) {
//                Text(AppStrings.confirmPassword)
//                    .customFont(.semiBold, 14)
//                    .foregroundStyle(Color.textFieldIconBackground)
//
//                SecureInputField(icon: "lock", placeholder: AppStrings.enterNewPassword, text: $vm.confirmPassword)
//                
//                if !vm.confirmPassword.isEmpty && vm.newPassword != vm.confirmPassword {
//                    Text(AppStrings.passwordNotMatch)
//                        .customFont(.regular, 12)
//                        .foregroundColor(.red)
//                }
//            }
//            
//            // Change Password Button
//            if !vm.oldPassword.isEmpty || !vm.newPassword.isEmpty || !vm.confirmPassword.isEmpty {
//                
//                
//                CustomButton(title: AppStrings.updatePassword, action: {
//                    Task { await vm.changePassword() }
//                })
//                .disabled(!vm.isPasswordValid || vm.isLoading)
//            }
//        }
//    }
    
    // MARK: - Save Button
    var saveButton: some View {
        
        CustomButton(title: AppStrings.saveChanges, backgroundColor: vm.isFormValid ? Color.buttonBackground : Color.gray.opacity(0.3)){
            Task { await vm.updateProfile() }
        }
        .disabled(!vm.isFormValid || vm.isLoading)
    }
}

// MARK: - Image Picker
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.selectedImage = selectedImage
            }
            parent.dismiss()
        }
    }
}
