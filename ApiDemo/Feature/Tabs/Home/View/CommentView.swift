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
    @State var vm: CommentViewModel
    @Bindable var session: SessionManager  // ✅ works perfectly with @Observable
    
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    init(post: Post,viewModel: CommentViewModel, session: SessionManager) {
        _vm = State(wrappedValue: viewModel)
        self.session = session
        self.post = post
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 🔝 Header
            HStack {
                Spacer()
                Text("Comments")
                    .customFont(.semiBold, 18)
                    .foregroundStyle(.primaryText)

                Spacer()
            }
            .padding()
            .padding(.top, 10)
            
            Divider()
            
            // 📜 Comment List
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    if vm.comments.isEmpty && !vm.isLoading {
                        Spacer()
                            .frame(height: 50)
                        
                        Text("No comments yet")
                            .customFont(.medium, 15)
                            .foregroundStyle(.secondaryText)
                            
                        Spacer()
                    }
                    
                    else {
                        ForEach(vm.comments) { comment in
                            
                            CommentRowView(comment: comment, vm: vm)
                                .onAppear {
                                    if comment.id == vm.comments.last?.id {
                                        Task {
                                            await vm.fetchMoreComments(postId: post.id)
                                        }
                                    }
                                }
                        }
                        
                        if vm.isLoading {
                            ProgressView()
                        }

                    }
                }
                .padding(.top, 10)
            }
            
            Divider()
            
            // ✍️ Input Bar (Instagram style)
            VStack(spacing: 6) {
                
                // 🔁 Replying UI
                if let replying = vm.replyingTo {
                    Spacer()
                        .frame(height: 10)
                    HStack {
                        avatarSmall(replying.user.name)
                        VStack(alignment: .leading) {
                            Text("Replying to \(replying.user.name)")
                                .customFont(.medium, 14)
                                .foregroundStyle(.primaryText)
                            Text(replying.text)
                                .customFont(.regular, 13)
                                .foregroundStyle(.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button("Cancel") {
                            vm.replyingTo = nil
                        }
                        .customFont(.medium, 14)
                        .foregroundStyle(.likeBackground)
                    }
                    .padding(.horizontal)
                }
                
                // ✍️ Input
                HStack(spacing: 10) {
                    
                    avatarSmall(session.user?.name ?? "A")
                    
                    TextField(
                        vm.replyingTo == nil ? "Add a comment..." : "Write a reply...",
                        text: $text
                    )
                    .focused($isFocused)
                    .padding(10)
                    .background(Color.textFieldBackground)
                    .cornerRadius(20)
                    
                    Button("Post") {
                        Task {
                            
                            if let parent = vm.replyingTo {
                                await vm.addReply(
                                    postId: post.id,
                                    parentId: parent.parentCommentId ?? parent.id,
                                    text: text
                                )
                            } else {
                                await vm.addComment(postId: post.id, text: text)
                            }
                            
                            text = ""
                            vm.replyingTo = nil
                            isFocused = false
                        }
                    }
                    .customFont(.semiBold)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
            }
            .background(Color.appSecondaryBackground)
        }
        .background(Color.appBackground)
        .onAppear {
            Task {
                await vm.fetchComments(postId: post.id)
            }
        }
    }
}

struct CommentRowView: View {
    
    let comment: Comment
    @Bindable var vm: CommentViewModel
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // 🔹 Main Comment Row
            commentView(comment: comment)
            
            // 🔁 View Replies Button
            let isExpanded = vm.expandedComments.contains(comment.id)

            if comment.replyCount > 0 {
                
                Button {
                    withAnimation(.easeInOut) {
                        vm.toggleReplies(commentId: comment.id)
                    }
                    if vm.repliesMap[comment.id] == nil {
                        Task {
                            await vm.fetchReplies(commentId: comment.id)
                        }
                    }
                    
                } label: {
                    HStack {
                        Rectangle()
                            .frame(width: 20, height: 1)
                            .foregroundColor(.secondaryText.opacity(0.5))
                        
                        Text(isExpanded
                             ? "Hide replies"
                             : "View \(comment.replyCount) replies")
                        .customFont(.medium, 13)
                        .foregroundColor(.secondaryText)
                    }
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            
            // 🔁 Replies List
            if isExpanded {
                
                let replies = vm.repliesMap[comment.id] ?? []
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    ForEach(replies) { reply in
                        
                        commentView(comment: reply)
                        .onAppear {
                            // 🔥 Reply pagination trigger
                            if reply.id == replies.last?.id,
                               vm.hasMoreReplies[comment.id] == true {
                                
                                Task {
                                    await vm.fetchReplies(commentId: comment.id)
                                }
                            }
                        }
                    }
                    
                    // 🔄 Loader
                    if vm.loadingReplies.contains(comment.id) {
                        ProgressView()
                            .padding(.leading, 46)
                    }
                }
                .padding(.leading, 46)
            }
        }
        .padding(.horizontal)
        .contentShape(Rectangle()) // ✅ prevents weird tap overlap
    }
    
    @ViewBuilder
    func commentView(comment: Comment)-> some View {
        HStack(alignment: .top, spacing: 10) {
            
            avatarSmall(comment.user.name)
            
            VStack(alignment: .leading, spacing: 4) {
                
                // ✅ Username + Text (Instagram style)
                HStack {
                    Text("\(comment.user.name) ")
                        .customFont(.semiBold,16)
                        .foregroundStyle(.primaryText)
                    Text(timeAgo(comment.createdAt))
                        .customFont(.regular,13)
                        .foregroundStyle(.secondaryText)
                }
              
                Text(comment.text)
                    .customFont(.regular,14)
                    .foregroundStyle(.primaryText)


                
                Button {
                    vm.replyingTo = comment
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.becomeFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                } label: {
                    Text("Reply")
                        .customFont(.medium, 14)
                        .foregroundStyle(.likeBackground)
                }
                .buttonStyle(.plain)
                
            }
            
            Spacer()
            
            // ❤️ Like Button (Right side)
            VStack {
                Button {
                    withAnimation(.easeInOut) {
                        vm.toggleLike(commentId: comment.id)
                    }
                } label: {
                    Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(comment.isLiked ? .likeBackground : .textFieldIconBackground)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle()) // ✅ precise tap area
                
                if comment.likeCount > 0 {
                    Text("\(comment.likeCount)")
                        .customFont(.regular, 13)
                        .foregroundStyle(.secondaryText)
                }
            }
        }
    }

}
// MARK: - Helper

func avatarSmall(_ name: String) -> some View {
    ZStack {
        Circle()
            .fill(dynamicColor(for: name))
            .frame(width: 36, height: 36)
        Text(name.prefix(1))
            .customFont(.medium, 14)
            .foregroundColor(.white)
    }
} 
