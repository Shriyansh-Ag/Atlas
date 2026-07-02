import SwiftUI

public struct QuickActionButton: View {
    public let title: String
    public let icon: String
    public let color: Color
    public let action: () -> Void
    
    public init(title: String, icon: String, color: Color = Color.Atlas.primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: Spacing.small) {
                ZStack {
                    Circle()
                        .fill(Color.Atlas.surface)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .atlasFont(AtlasTypography.caption(weight: .medium))
                    .foregroundColor(Color.Atlas.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
