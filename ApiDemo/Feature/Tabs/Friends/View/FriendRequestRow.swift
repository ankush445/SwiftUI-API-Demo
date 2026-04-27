//
//  FriendRequestRow.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import SwiftUI
struct FriendRequestRow: View {
    
    let request: FriendRequestModel
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            
            // 👤 Avatar
            Text(request.requester.name.prefix(1))
                .customFont(.semiBold, 16)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            // 🧾 Info
            VStack(alignment: .leading, spacing: 4) {
                
                Text(request.requester.name)
                    .customFont(.semiBold, 16)
                    .foregroundStyle(.primaryText)
                    .lineLimit(1)
                
                Text(request.requester.username)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondaryText)
                    .lineLimit(1)
                
                Text(AppStrings.wantsToFollowYou)
                    .customFont(.regular, 12)
                    .foregroundStyle(.secondaryText)
            }
            
            Spacer(minLength: 8)
            
            // 🎯 Actions
            if request.isLoading {
                ProgressView()
                    .frame(width: 60)
            } else {
                HStack(spacing: 10) {
                    
                    // ✅ Accept
                    Button(action: onAccept) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.buttonBackground)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(AppStrings.accept)
                    
                    // ❌ Reject
                    Button(action: onReject) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primaryText)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(AppStrings.delete)
                }
            }
        }
    }
}


struct FriendRequestShimmerRow: View {
    var body: some View {
        HStack(spacing: 12) {
            
            // Avatar shimmer
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .shimmer()
            
            VStack(alignment: .leading, spacing: 6) {
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 14)
                    .shimmer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 90, height: 12)
                    .shimmer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 10)
                    .shimmer()
            }
            
            Spacer()
            
            // Buttons shimmer
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .shimmer()
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .shimmer()
            }
        }
    }
}
