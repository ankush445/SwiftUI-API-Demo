//
//  SuggestedFriendRow.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import SwiftUI
struct SuggestedFriendRow: View {
    
    let suggestUser: SuggestFriendModel
    let onAdd: () -> Void
    let onTapProfile: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            
            // 👤 Avatar
            Text(suggestUser.name.prefix(1))
                .customFont(.semiBold, 18)
                .frame(width: 48, height: 48)
                .background(dynamicColor(for: suggestUser.name))
                .foregroundColor(.white)
                .clipShape(Circle())
            
            // 🧾 Info
            VStack(alignment: .leading, spacing: 4) {
                
                Text(suggestUser.name)
                    .customFont(.semiBold, 15)
                    .foregroundStyle(.primaryText)
                    .lineLimit(1)
                
                Text(suggestUser.username)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondaryText)
                    .lineLimit(1)
                
                // 👥 Mutual Friends
                if suggestUser.mutualCount > 0 {
                    HStack(spacing: 6) {
                        
                        ZStack(alignment: .leading) {
                            ForEach(Array(suggestUser.mutualUsers.prefix(3).enumerated()), id: \.offset) { index, user in
                                
                                Text(user.name.prefix(1))
                                    .customFont(.semiBold, 9)
                                    .frame(width: 20, height: 20)
                                    .background(dynamicColor(for: user.name))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .offset(x: CGFloat(index * 14))
                            }
                        }
                        
                        
                        Text(mutualText)
                            .customFont(.regular, 11)
                            .foregroundStyle(.secondaryText)
                    }
                }
            }
            .onTapGesture {
                onTapProfile()
            }
            
            Spacer(minLength: 8)
            
            // 🎯 Follow Button
            Button(action: {
                onAdd()
            }) {
                if suggestUser.isLoading {
                    ProgressView()
                        .frame(width: 80, height: 30)
                } else {
                    Text(buttonTitle)
                        .customFont(.semiBold, 13)
                        .foregroundColor(buttonTextColor)
                        .frame(width: 90, height: 32)
                        .background(buttonBackground)
                        .clipShape(Capsule())
                }
            }
            .disabled(suggestUser.isLoading)
        }
        .contentShape(Rectangle()) // 👈 full row tappable
    }
    private var buttonBackground: Color {
        suggestUser.followStatus == .none
        ? .buttonBackground
        : Color.gray.opacity(0.15)
    }
    private var buttonTextColor: Color {
        suggestUser.followStatus == .none
        ? .white
        : .primaryText
    }
    private var buttonTitle: String {
        switch suggestUser.followStatus {
        case .none: return AppStrings.follow
        case .pending: return AppStrings.requested
        case .following: return AppStrings.unfollow
        case .follower: return AppStrings.followBack
        case .mutual: return AppStrings.message
        }
    }
    
    private var mutualText: String {
        if suggestUser.mutualCount == 1 {
            return AppStrings.oneMutualFriend
        } else {
            return "\(suggestUser.mutualCount)  \(AppStrings.oneMutualFriend)"
        }
    }
}
