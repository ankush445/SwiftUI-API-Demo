//
//  CreatePostView.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import SwiftUI

struct CreatePostView: View {

    @Environment(\.dismiss) private var dismiss
    @Bindable var session: SessionManager  // ✅ works perfectly with @Observable

    @State private var title = ""
    @State private var description = ""
    @FocusState private var focusedField: Field?

    let onPost: (String, String?) -> Void

    private enum Field {
        case title, description
    }

    private var isPostEnabled: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    private var remainingChars: Int { 280 - title.count - description.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Avatar + Fields Row
                    HStack(alignment: .top, spacing: 12) {
                        avatarView

                        VStack(alignment: .leading, spacing: 8) {
                            // Title Field
                            TextField("What's on your mind?", text: $title, axis: .vertical)
                                .font(.body)
                                .focused($focusedField, equals: .title)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .description }

                            Divider()

                            // Description Field
                            TextField("Add a description...", text: $description, axis: .vertical)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .focused($focusedField, equals: .description)
                                .submitLabel(.done)
                                .onSubmit {
                                    if isPostEnabled { submitPost() }
                                }
                        }
                    }
                    .padding(16)

                    Divider()

                    // Bottom Toolbar
                    HStack(spacing: 4) {
                        toolbarButton(icon: "photo") { }
                        toolbarButton(icon: "mappin.circle") { }
                        toolbarButton(icon: "face.smiling") { }

                        Spacer()

                        // Character counter
                        Text("\(remainingChars)")
                            .font(.caption)
                            .foregroundStyle(remainingChars < 20 ? .red : .secondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
            .scrollDismissesKeyboard(.interactively) // ✅ swipe down dismisses keyboard
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New post")
                        .font(.headline)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        submitPost()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                    .disabled(!isPostEnabled || remainingChars < 0)
                }
            }
            // ✅ Keyboard toolbar with Done button
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .onAppear {
            focusedField = .title // ✅ auto-focus on open
        }
    }

    // MARK: - Subviews

    private var avatarView: some View {
        Circle()
            .fill(Color.blue.opacity(0.15))
            .frame(width: 38, height: 38)
            .overlay(
                Text("Y")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
            )
    }

    private func toolbarButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
        }
    }

    // MARK: - Actions

    private func submitPost() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedDesc = description.trimmingCharacters(in: .whitespaces)
        onPost(trimmedTitle, trimmedDesc.isEmpty ? nil : trimmedDesc)
        dismiss()
    }
}
