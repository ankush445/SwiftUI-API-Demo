//
//  AppStrings.swift
//  ApiDemo
//
//  Created by ios-22 on 23/04/26.
//
import Foundation
enum AppStrings {
    
    // MARK: - Auth Titles
    static let appName = localized("auth.app_name")
    static let loginSubtitle = localized("auth.login_subtitle")
    static let signupSubtitle = localized("auth.signup_subtitle")
    
    // MARK: - Fields
    static let fullName = localized("auth.full_name")
    static let email = localized("auth.email")
    static let password = localized("auth.password")
    static let username = localized("auth.username")
    static let usernameInvalidFormat = localized("auth.username_invalid_format")
    static let checking = localized("auth.checking")
    static let usernameAvailable = localized("auth.username_available")
    static let usernameTaken = localized("auth.username_taken")
    static let resetPassword = localized("auth.reset_password")
    static let resetPasswordSubtitle = localized("auth.reset_password_subtitle")
    static let newPassword = localized("auth.new_password")
    static let confirmPassword = localized("auth.confirm_password")
    static let updatePassword = localized("auth.update_password")
    static let invalidName = localized("auth.invalid_name")
    static let invalidEmail = localized("auth.invalid_email")
    static let invalidPassword = localized("auth.invalid_password")
    static let passwordNotMatch = localized("auth.password_not_match")
    static let somethingWentWrong = localized("auth.something_wrong")
    
    // MARK: - Buttons
    static let login = localized("auth.login")
    static let signUp = localized("auth.signup")
    
    // MARK: - Other
    static let forgotPassword = localized("auth.forgot_password")
    static let orContinue = localized("auth.or_continue")
    
    // MARK: - Toggle
    static let noAccount = localized("auth.no_account")
    static let alreadyAccount = localized("auth.already_account")
    
    // MARK: - Social
    static let google = localized("auth.google")
    static let facebook = localized("auth.facebook")
    
    // MARK: - Tabs
    static let home = localized("tab.home")
    static let friends = localized("tab.friends")
    static let create = localized("tab.create")
    static let messages = localized("tab.messages")
    static let profile = localized("tab.profile")
    
    static let search = localized("tab.search")
    static let suggested = localized("suggested")
    static let friendRequests = localized("friendRequests")
    static let seeAll = localized("seeAll")
    static let requested = localized("requested")
    static let follow = localized("follow")
    static let followBack = localized("followBack")

    static let followers = localized("followers")
    static let following = localized("following")
    static let unfollow = localized("unfollow")

    static let message = localized("message")
    static let wantsToFollowYou = localized("wantsToFollowYou")
    static let accept = localized("accept")
    static let delete = localized("delete")
    static let results = localized("results")
    static let noUsersFound = localized("no_users_found")
    static let noFriendsYet = localized("no_friends_yet")
    static let posts = localized("posts")
    static let noPostYet = localized("noPostYet")
    static let editProfile = localized("editProfile")

    static let noFollowers = localized("no_followers")
    static let noFollowing = localized("no_following")
    static let noResults = localized("no_results")
    static let tryDifferentKeyword = localized("try_different_keyword")
    static let noFollowersSubtitle = localized("no_followers_subtitle")
    static let noFollowingSubtitle = localized("no_following_subtitle")
    static let oneMutualFriend = localized("one_mutual_friend")
    static let mutualFriends = localized("mutual_friends")
    static let tapToChangeProfile = localized("tapToChangeProfile")
    static let bio = localized("bio")
    static let website = localized("website")
    
    
    static let changePassword = localized("changePassword")
    static let currentPassword = localized("currentPassword")
    static let enterCurrentPassword = localized("enterCurrentPassword")
    static let enterNewPassword = localized("enterNewPassword")
    static let confirmNewPassword = localized("confirmNewPassword")
    static let saveChanges = localized("saveChanges")
    
    static let settings = localized("settings")
    static let account = localized("account")
    static let myPosts = localized("myPosts")
    static let viewYourPosts = localized("viewYourPosts")
    static let updateYourInfo = localized("updateYourInfo")
    static let savedPosts = localized("savedPosts")
    static let bookmarkedPosts = localized("bookmarkedPosts")

    static let preferences = localized("preferences")
    static let notifications = localized("notifications")
    static let manageNotifications = localized("manageNotifications")
    static let privacySecurity = localized("privacySecurity")
    static let controlProfileVisibility = localized("controlProfileVisibility")
    static let blockedUsers = localized("blockedUsers")
    static let manageBlockedAccounts = localized("manageBlockedAccounts")

    static let support = localized("support")
    static let helpCenter = localized("helpCenter")
    static let getHelpSupport = localized("getHelpSupport")
    static let termsConditions = localized("termsConditions")
    static let readTerms = localized("readTerms")
    static let privacyPolicy = localized("privacyPolicy")
    static let readPrivacyPolicy = localized("readPrivacyPolicy")
    static let aboutApp = localized("aboutApp")
    static let appVersion = localized("appVersion")

    static let dangerZone = localized("dangerZone")
    static let deleteAccount = localized("deleteAccount")
    static let deleteAccountDesc = localized("deleteAccountDesc")
    static let logout = localized("logout")
    static let logoutDesc = localized("logoutDesc")

    static let logoutTitle = localized("logoutTitle")
    static let logoutMessage = localized("logoutMessage")
    static let deleteTitle = localized("deleteTitle")
    static let deleteMessage = localized("deleteMessage")
    static let cancel = localized("cancel")




    
    


    

}

// 🔑 Localization Helper
private func localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
