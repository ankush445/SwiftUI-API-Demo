
import SwiftUI

public struct LoadingModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var isLoading: Bool
    var loadingText: String
    
    public init(isLoading: Bool, loadingText: String) {
        self.isLoading = isLoading
        self.loadingText = loadingText
    }

    public func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading) // Disable interactions when loading
            
            if isLoading {
                GeometryReader { geometry in
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    VStack {
                        Spacer()
                        VStack {
                            ProgressView(loadingText)
                                .progressViewStyle(CircularProgressViewStyle())
                                .controlSize(.large)
                                .tint(colorScheme == .dark ? .white : .gray)
                                .padding()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical)
                        .background(
                            loadingText != ""
                                ? Color(uiColor: UIColor.secondarySystemBackground) // auto adapts to dark/light mode
                                : Color.clear
                        )
                        .cornerRadius(12)
                        Spacer()
                       
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

public extension View {
    func loadingIndicator(isLoading: Bool,message: String = "") -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading, loadingText: message))
    }
}
