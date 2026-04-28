//
//  FollowTopBar.swift
//  ApiDemo
//
//  Created by ios-22 on 28/04/26.
//
import SwiftUI

struct FollowTopBar: View {
    
    let selected: FollowTab
    let onSelect: (FollowTab) -> Void
    
    var body: some View {
        HStack {
            
            tabItem(title: AppStrings.followers, tab: .followers)
            tabItem(title:AppStrings.following, tab: .following)
        }
        .padding(.horizontal)
    }
    
    func tabItem(title: String, tab: FollowTab) -> some View {
        VStack(spacing: 6) {
            
            Text(title)
                .customFont(.semiBold, 14)
                .foregroundColor(selected == tab ? .primary : .gray)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(selected == tab ? .primary : .clear)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            onSelect(tab)
        }
    }
}
