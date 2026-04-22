//
//  PostCardView.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import SwiftUI
struct PostCardView: View {
    
    let post: Post
    let onLike: () -> Void
    let onComment: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 👤 Header
            HStack {
                Text(post.user.name.prefix(1))
                    .frame(width: 40, height: 40)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                
                Text(post.user.name)
                    .font(.headline)
                
                Spacer()
                
                Text(timeAgo(post.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 📝 Content
            Text(post.title)
                .font(.headline)
            
            if let desc = post.content {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // ❤️ Actions
            HStack {
                Button(action: onLike) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(post.isLiked ? .red : .gray)
                    Text("\(post.likeCount)")
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: onComment) {
                      Image(systemName: "bubble.right")
                      Text("\(post.commentCount)")
                  }
                .buttonStyle(.plain)

            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}
