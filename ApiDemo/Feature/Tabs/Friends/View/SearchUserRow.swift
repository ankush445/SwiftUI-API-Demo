//
//  SearchUserRow.swift
//  ApiDemo
//
//  Created by ios-22 on 27/04/26.
//

import SwiftUI
struct SearchUserRow: View {
    
    let user: SearchUserModel
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            
            Text(user.name.prefix(1))
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .customFont(.semiBold, 16)
                    .foregroundStyle(.primaryText)
                
                Text(user.username)
                    .customFont(.regular, 13)
                    .foregroundStyle(.secondaryText)
            }
            
            Spacer()
            
            Button(action: onTap) {
                if user.isLoading {
                    ProgressView()
                        .frame(minWidth: 90)
                } else {
                    Text(buttonTitle)
                        .customFont(.semiBold, 14)
                        .foregroundColor(user.followStatus == .none ? .white : .primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            user.followStatus == .none ? Color.buttonBackground : Color.gray.opacity(0.2)
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var buttonTitle: String {
        switch user.followStatus {
        case .none: return AppStrings.follow
        case .pending: return AppStrings.requested
        case .following: return AppStrings.following
        }
    }
}
