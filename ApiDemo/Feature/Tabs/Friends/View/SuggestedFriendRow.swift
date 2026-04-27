//
//  SuggestedFriendRow.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import SwiftUI
struct SuggestedFriendRow: View {
    @State private var isFollowing = false

    let suggestUser: SuggestFriendModel
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            Text(suggestUser.name.prefix(1))
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
            VStack(alignment: .leading){
                Text(suggestUser.name)
                    .customFont(.semiBold, 16)
                    .foregroundStyle(.primaryText)

                Text(suggestUser.username)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondaryText)
                
                if suggestUser.mutualCount > 0 {
                    HStack(spacing: 6) {
                        
                        // 👥 Overlapping avatars (max 3)
                        ZStack {
                            ForEach(Array(suggestUser.mutualUsers.enumerated()), id: \.offset) { index, user in
                                
                                Text(user.name.prefix(1))
                                    .customFont(.semiBold, 10)
                                    .frame(width: 22, height: 22)
                                    .background(dynamicColor(for: user.name))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .offset(x: CGFloat(index * 12))
                            }
                        }
                        .frame(width: 40, alignment: .leading)
                        
                        // 📝 Text
                        Text(mutualText)
                            .customFont(.regular, 12)
                            .foregroundStyle(.secondaryText)
                    }
                }
                
            }
          
            Spacer()
            
            Button(action: {
                onAdd()
            }) {
                if suggestUser.isLoading {
                    ProgressView()
                        .frame(minWidth: 90)
                } else {
                    Text(buttonTitle)
                        .customFont(.semiBold, 14)
                        .foregroundColor(suggestUser.followStatus == .none ? .white : .primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(minWidth: 90)
                        .background(
                            suggestUser.followStatus == .none ? Color.buttonBackground : Color.gray.opacity(0.2)
                        )
                        .clipShape(Capsule())
                }
            }
            .disabled(suggestUser.isLoading)
            .animation(.easeInOut, value: suggestUser.followStatus)
        }
    }
    
    private var buttonTitle: String {
        switch suggestUser.followStatus {
        case .none: return AppStrings.follow
        case .pending: return AppStrings.requested
        case .following: return AppStrings.following
        }
    }
    
    private var mutualText: String {
        let names = suggestUser.mutualUsers.prefix(2).map { $0.name }
        
        if names.isEmpty {
            return "\(suggestUser.mutualCount) mutual friends"
        }
        
        if names.count == 1 {
            return "\(names[0]) + \(suggestUser.mutualCount - 1) mutual friends"
        }
        
        return "\(names[0]), \(names[1]) + \(suggestUser.mutualCount - 2) mutual friends"
    }
}
