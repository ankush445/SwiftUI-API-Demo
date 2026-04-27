import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.textFieldIconBackground)
            
            TextField(placeholder, text: $text)
                .customFont(.regular, 16)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .autocorrectionDisabled(true)
                .submitLabel(.done)
            
            if !text.isEmpty {
                Button {
                    HapticManager.trigger(.light)
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.textFieldIconBackground)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        // 🔥 FULL BACKGROUND + ROUNDING
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.textFieldBackground)
        )
        // 🔥 Focus Border (optional but premium)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isFocused ? Color.buttonBackground : Color.clear, lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .frame(height: 44) // ✅ Fixed height for visibility
    }
}

#Preview {
    CustomSearchBar(text: .constant(""), placeholder: "Search...")
        .padding()
        .background(Color.gray.opacity(0.1))
}
