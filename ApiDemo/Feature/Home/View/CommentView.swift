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
                    
                    if vm.comments.isEmpty && !vm.isCommentLoading {
                        Text("No comments yet")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    }
                    
                    else {
                        ForEach(vm.rootComments) { comment in
                            CommentRowView(
                                comment: comment,
                                replies: vm.replies(for: comment),
                                vm: vm,
                                postId: post.id
                            )
                            .onAppear {
                                   // 🔥 pagination trigger
                                   if comment.id == vm.rootComments.last?.id {
                                       Task {
                                           await vm.fetchMoreComments(postId: post.id)
                                       }
                                   }
                               }
                        }
                        if vm.isCommentLoading && !vm.comments.isEmpty {
                            ProgressView()
                                .padding()
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
    let replies: [Comment]
    @Bindable var vm: HomeViewModel
    let postId: String
    
    @State private var showReplyField = false
    @State private var replyText = ""
    @State private var isLiked = false
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // 🔹 Main Comment
            HStack(alignment: .top, spacing: 10) {
                
                avatar
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    header
                    
                    Text(comment.text)
                        .font(.subheadline)
                    
                    actions
                }
                
                Spacer()
            }
            
            // 🔁 Replies
            if !replies.isEmpty {
                
                Button(isExpanded ? "Hide replies" : "View replies (\(replies.count))") {
                    isExpanded.toggle()
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 46)
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(replies) { reply in
                            HStack(alignment: .top, spacing: 10) {
                                
                                avatarSmall(reply.user.name)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reply.user.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    
                                    Text(reply.text)
                                        .font(.caption)
                                    
                                    Text(reply.createdAt, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.leading, 46)
                }
            }
            
            // ✍️ Reply Input
            if showReplyField {
                HStack {
                    TextField("Reply...", text: $replyText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Send") {
                        vm.addReply(
                            postId: postId,
                            parentId: comment.id,
                            text: replyText
                        )
                        replyText = ""
                        showReplyField = false
                    }
                }
                .padding(.leading, 46)
            }
        }
        .padding(.horizontal)
    }
    
    var avatar: some View {
        ZStack {
            Circle()
                .fill(dynamicColor(for: comment.user.name))
                .frame(width: 36, height: 36)
            
            Text(comment.user.name.prefix(1))
                .foregroundColor(.white)
        }
    }
    
    
    func avatarSmall(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(dynamicColor(for: name))
                .frame(width: 28, height: 28)
            
            Text(name.prefix(1))
                .font(.caption)
                .foregroundColor(.white)
        }
    }
    
    var header: some View {
        HStack {
            Text(comment.user.name)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(comment.createdAt, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    var actions: some View {
        HStack(spacing: 16) {
            
            Button {
                isLiked.toggle()
                HapticManager.trigger(.light)
                
                // 🔥 Call API here
//                vm.likeComment(commentId: comment.id)
                
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .red : .gray)
            }
            
            Text("\(comment.likesCount)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button("Reply") {
                showReplyField.toggle()
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
    }
}

// MARK: - Helper

private func dynamicColor(for name: String) -> Color {
    let hash = abs(name.hashValue)
    let hue = Double(hash % 256) / 255.0
    return Color(hue: hue, saturation: 0.6, brightness: 0.8)
}
