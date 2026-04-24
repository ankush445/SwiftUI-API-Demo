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
    var randomImageUrl: String? {
        // Random images (you can replace with API later)
        let images = [
            "https://picsum.photos/400/300",
            "https://picsum.photos/401/300",
            "https://picsum.photos/402/300",
            "https://picsum.photos/403/300"
        ]
        
        return images.randomElement()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 👤 Header
            HStack {
                Text(post.user.name.prefix(1))
                    .frame(width: 40, height: 40)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    Text(post.user.username)
                        .customFont(.semiBold, 16)
                        .foregroundStyle(.primaryText)

                    Text(timeAgo(post.createdAt))
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                }
               
                
                Spacer()
                
                Menu {
                    Button("Report") {
                        print("Edit tapped")
                    }
                    
                    Button("Delete") {
                        print("Delete tapped")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90)) // makes it vertical (⋮)
                        .customFont(.semiBold, 16)
                        .foregroundStyle(.secondaryText)
                }
               
            }
            
            // 📝 Content
            Text(post.title)
                .customFont(.medium, 16)
                .foregroundStyle(.primaryText)
            if let imageUrl = randomImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
            }

           
            // ❤️ Actions
            HStack {
                Button(action: onLike) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(post.isLiked ? .likeBackground : .textFieldIconBackground)
                    Text("\(post.likeCount)")
                        .foregroundStyle(post.isLiked ? .likeBackground : .textFieldIconBackground)

                }
                .buttonStyle(.plain)
                
               
                
                Button(action: onComment) {
                      Image(systemName: "bubble.right")
                        .foregroundStyle(.textFieldIconBackground)

                      Text("\(post.commentCount)")
                        .foregroundStyle(.textFieldIconBackground)

                  }
                .buttonStyle(.plain)
                Button(action: {}) {
                      Image(systemName: "square.and.arrow.up.fill")
                        .foregroundStyle(.textFieldIconBackground)

                  }
                .buttonStyle(.plain)
                Spacer()
                Button(action: {}) {
                      Image(systemName: "bookmark.fill")
                        .foregroundStyle(.textFieldIconBackground)

                  }
                .buttonStyle(.plain)

            }
            
            if let desc = post.content {
                
                Text(makeCaption(
                    username: post.user.username,
                    content: desc
                ))
                .font(.system(size: 14))
                .foregroundStyle(.primaryText)
            }
            
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

struct PostCardShimmer: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 14)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            
            // Title
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 16)
            // Image shimmer (🔥 NEW)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
            // Description
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 14)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 14)
            
            // Actions
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 14)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30, height: 14)
            }
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(15)
        .shimmer()
    }
}
