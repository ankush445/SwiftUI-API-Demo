//
//  FollowerRow.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//

import SwiftUI
struct FollowerRow: View {
    
    let user: FollowerModel
    let follower: Bool

    let onFollow: () -> Void
    let onRemove: () -> Void   // 👈 NEW
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Avatar
            Text(user.name.prefix(1))
                .customFont(.semiBold, 16)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .customFont(.semiBold, 16)
                    .foregroundStyle(.primaryText)
                    .lineLimit(1)
                
                Text(user.username)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Button
            
            HStack {
                Button {
                    onFollow()
                } label: {
                    if user.isLoading {
                        ProgressView()
                            .frame(width: 80)
                    } else {
                        Text(buttonTitle)
                            .customFont(.semiBold, 13)
                            .foregroundColor(buttonTextColor)
                            .lineLimit(1)                 // ✅ prevent wrapping
                            .minimumScaleFactor(0.8)      // ✅ shrink if needed
                            .frame(width: 100, height: 32) // ✅ fixed width (important)
                            .background(buttonBackground)
                            .clipShape(Capsule())
                    }
                }
                if follower {
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primaryText)
                            .frame(width: 32, height: 32)
                        
                    }
                    .accessibilityLabel(AppStrings.delete)
                }
            }
        }
    }
    
    private var buttonTitle: String {
        switch user.relationType {
        case .pending: return AppStrings.requested
        case .follower: return AppStrings.followBack
        case .mutual: return AppStrings.message
        case .following: return AppStrings.unfollow
        }
    }
    
    private var buttonBackground: Color {
        user.relationType == .follower ? .buttonBackground : Color.gray.opacity(0.2)
    }
    
    private var buttonTextColor: Color {
        user.relationType == .follower ? .white : .primaryText
    }
}
