import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .atlasFont(AtlasTypography.headline(weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.medium)
            .padding(.horizontal, Spacing.large)
            .background(Color.Atlas.primary)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.fullyRounded, style: .continuous))
            .shadow(color: Color.Atlas.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(SpringButtonStyle())
    }
}

public struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .atlasFont(AtlasTypography.headline(weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.medium)
            .padding(.horizontal, Spacing.large)
            .background(Color.Atlas.surface.opacity(0.5))
            .foregroundColor(Color.Atlas.textPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.fullyRounded, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.fullyRounded, style: .continuous))
        }
        .buttonStyle(SpringButtonStyle())
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AtlasAnimations.springBouncy, value: configuration.isPressed)
    }
}
