//
//  CommentView.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//

import SwiftUI
import SwiftUI_Loader

struct CommentView: View {
    
    let post: Post
    @Bindable var vm: HomeViewModel
    @Bindable var session: SessionManager  // ✅ works perfectly with @Observable
    
    @State private var text = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 🔝 Header
            HStack {
                Text("Comments")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Divider()
            
            // 📜 Comment List
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    if vm.comments.isEmpty {
                        Text("No comments yet")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    }
                    
                    else {
                        ForEach(vm.comments) { comment in
                            CommentRowView(comment: comment)
                        }
                    }
                }
                .padding(.top, 10)
            }
            
            Divider()
            
            // ✍️ Input Bar (Instagram style)
            HStack(spacing: 10) {
                
                ZStack {
                    Circle()
                        .fill(dynamicColor(for: session.user?.name ?? "A"))
                        .frame(width: 36, height: 36)
                    
                    Text(session.user?.name.prefix(1) ?? "A")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                TextField("Add a comment...", text: $text)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button("Post") {
                    vm.addComment(postId: post.id, text: text)
                    text = ""
                }
                .fontWeight(.semibold)
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color(.systemGroupedBackground))
        .loadingIndicator(isLoading: vm.isCommentLoading)
        .onAppear {
            Task {
                await vm.fetchComments(postId: post.id)
            }
        }
    }
}


struct CommentRowView: View {
    
    let comment: Comment
    @State private var isLiked = false
    @State private var likeCount = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            
            // 👤 Avatar
            ZStack {
                Circle()
                    .fill(dynamicColor(for: comment.user.name))
                    .frame(width: 36, height: 36)
                
                Text(comment.user.name.prefix(1))
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                
                // 👤 Name + Comment
                HStack{
                    Text("\(comment.user.name) ")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(comment.createdAt, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text(comment.text)
                        .font(.subheadline)
                    Spacer()
                    Button {
                        isLiked.toggle()
                        likeCount += isLiked ? 1 : -1
                        HapticManager.trigger(.light)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                            Text("\(likeCount)")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(isLiked ? .red : .gray)
                }
                
                Button("Reply") {
                    // 🔥 future: open reply input
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Helper

private func dynamicColor(for name: String) -> Color {
    let hash = abs(name.hashValue)
    let hue = Double(hash % 256) / 255.0
    return Color(hue: hue, saturation: 0.6, brightness: 0.8)
}
