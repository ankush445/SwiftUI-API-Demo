# Settings & Edit Profile Implementation Guide

## Overview
This implementation provides a complete Settings screen and Edit Profile screen following Instagram-like design patterns and your app's architecture.

## Files Created

### 1. Models
- **EditProfileModel.swift** - Data models for edit profile requests/responses
  - `EditProfileRequest` - Request payload for updating profile
  - `EditProfileResponse` - Response from server
  - `SettingsOption` - Settings menu item model

### 2. Repositories
- **EditProfileRepositoryProtocol.swift** - Protocol and implementation for edit profile API calls
  - `updateProfile()` - Update user profile information
  - `changePassword()` - Change user password

### 3. ViewModels
- **EditProfileViewModel.swift** - Manages edit profile form state and logic
  - Form validation
  - Profile update
  - Password change
  - Toast notifications

### 4. Views
- **EditProfileView.swift** - Edit profile screen with:
  - Profile picture upload
  - Basic info editing (name, username, bio, website)
  - Password change section
  - Form validation
  - Image picker integration

- **SettingsView.swift** - Settings screen with:
  - Profile card (quick access to edit profile)
  - Account settings section
  - Preferences section (notifications, privacy, blocked users)
  - Support section (help, terms, privacy policy, about)
  - Danger zone (delete account, logout)

## Architecture Pattern

### MVVM Structure
```
Model (EditProfileModel.swift)
  ↓
Repository (EditProfileRepositoryProtocol.swift)
  ↓
ViewModel (EditProfileViewModel.swift)
  ↓
View (EditProfileView.swift / SettingsView.swift)
```

### Navigation Integration
- Routes added to `ProfileRoute` enum in NavigationManager
- Navigation destinations configured in MainTabView
- Seamless navigation from ProfileView to Settings/EditProfile

## Features

### Edit Profile Screen
✅ Profile picture upload with camera icon
✅ Full name editing
✅ Username editing with validation (min 3 chars)
✅ Bio editing with character counter (max 150)
✅ Website URL (optional)
✅ Password change with confirmation
✅ Form validation
✅ Loading states
✅ Error handling with toast notifications

### Settings Screen
✅ Profile card with quick access to edit
✅ Account settings (My Posts, Edit Profile, Saved Posts)
✅ Preferences (Notifications, Privacy, Blocked Users)
✅ Support (Help, Terms, Privacy Policy, About)
✅ Danger zone (Delete Account, Logout)
✅ Organized sections with icons
✅ Consistent styling with your app theme

## Usage

### From ProfileView
```swift
// Edit Profile Button
Button {
    if let user = vm.profile?.toDomainUser() {
        nav.pushProfile(ProfileRoute.editProfile(user: user))
    }
}

// Settings Button
Button {
    nav.pushProfile(ProfileRoute.settings)
}
```

### From SettingsView
```swift
// Navigate to Edit Profile
nav.push(ProfileRoute.editProfile(user: user))

// Navigate to My Posts
nav.push(ProfileRoute.myPosts(userId: user.id))
```

## API Endpoints Required

Add these endpoints to your `APIEndpoint.swift`:

```swift
case updateProfile(request: EditProfileRequest)
case changePassword(oldPassword: String, newPassword: String)
```

## Customization

### Colors
- Uses your existing color scheme: `appBackground`, `appSecondaryBackground`, `buttonBackground`, etc.
- Icons use `buttonBackground` color for consistency

### Fonts
- Uses your custom font system: `customFont(.semiBold, 16)`, etc.

### Validation Rules
- Username: minimum 3 characters
- Bio: maximum 150 characters
- Password: minimum 6 characters
- Passwords must match for confirmation

## Integration Checklist

- [x] Models created
- [x] Repository protocol created
- [x] ViewModel created
- [x] Views created
- [x] Routes added to NavigationManager
- [x] Navigation destinations configured
- [x] AppDI updated with new repository
- [x] User model updated with new fields
- [ ] API endpoints implemented in backend
- [ ] Test edit profile functionality
- [ ] Test settings navigation
- [ ] Test form validation
- [ ] Test password change
- [ ] Test image upload

## Notes

- The implementation follows your existing MVVM + Repository pattern
- Uses `@Observable` for state management (matching your app)
- Includes proper error handling and loading states
- Toast notifications for user feedback
- Form validation before submission
- Image picker for profile picture upload
- All UI components match your app's design system
