import SwiftUI

public enum FancyToastStyle {
    case error
    case warning
    case success
    case info
}

public extension FancyToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        case .success: return .green
        }
    }
    
    var iconFileName: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

public struct FancyToast: Equatable {
    public var type: FancyToastStyle
    public var title: String
    public var message: String
    public var duration: Double = 2.5
    
    public init(type: FancyToastStyle, title: String, message: String, duration: Double = 2.5) {
        self.type = type
        self.title = title
        self.message = message
        self.duration = duration
    }
}

public struct FancyToastKit: View {
    var type: FancyToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    
    public init(
        type: FancyToastStyle,
        title: String,
        message: String,
        onCancelTapped: @escaping () -> Void
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.onCancelTapped = onCancelTapped
    }
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                
                Image(systemName: type.iconFileName)
                    .resizable()
                    .frame(width: isPad ? 24 : 20, height: isPad ? 24 : 20)
                    .foregroundColor(type.themeColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: isPad ? 21 : 16, weight: .semibold))
                    
                    Text(message)
                        .font(.system(size: isPad ? 20 : 14, weight: .medium))
                }
                
                Spacer(minLength: 10)
                
                Button {
                    onCancelTapped()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: isPad ? 20 : 16, height: isPad ? 20 : 16)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .background(Color(.systemGray6)) // replaced custom color
        .overlay(
            Rectangle()
                .fill(type.themeColor)
                .frame(width: 6),
            alignment: .leading
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
        .onAppear {
            UIAccessibility.post(
                notification: .announcement,
                argument: "\(title) \(message)"
            )
        }
    }
}
