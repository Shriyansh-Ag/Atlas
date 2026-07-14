import SwiftUI

public struct SettingsSection<Content: View>: View {
    public let title: String
    public let content: Content
    
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(title.uppercased())
                .atlasFont(.caption2)
                .foregroundColor(Color.Atlas.textSecondary)
                .padding(.horizontal, Spacing.small)
                .padding(.top, Spacing.medium)
            
            GlassCard(padding: 0) {
                VStack(spacing: 0) {
                    content
                }
            }
        }
    }
}

public struct SettingsNavigationRow<Destination: View>: View {
    public let title: String
    public let icon: String
    public let destination: Destination
    public let value: String?
    
    public init(title: String, icon: String, value: String? = nil, destination: Destination) {
        self.title = title
        self.icon = icon
        self.value = value
        self.destination = destination
    }
    
    public var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: Spacing.medium) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(Color.Atlas.primary)
                    .frame(width: 24)
                
                Text(title)
                    .atlasFont(.body)
                    .foregroundColor(Color.Atlas.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: Spacing.medium)
                
                if let value = value {
                    Text(value)
                        .atlasFont(.subheadline)
                        .foregroundColor(Color.Atlas.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.Atlas.textSecondary.opacity(0.5))
            }
            .padding()
        }
        Divider().padding(.leading, 56)
    }
}

public struct SettingsToggle: View {
    public let title: String
    public let icon: String
    @Binding public var isOn: Bool
    
    public init(title: String, icon: String, isOn: Binding<Bool>) {
        self.title = title
        self.icon = icon
        self._isOn = isOn
    }
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Color.Atlas.primary)
                .frame(width: 24)
            
            Toggle(title, isOn: $isOn)
                .atlasFont(.body)
                .tint(Color.Atlas.primary)
        }
        .padding()
        Divider().padding(.leading, 56)
    }
}

public struct DangerZoneCard: View {
    public let title: String
    public let description: String
    public let actionTitle: String
    public let action: () -> Void
    
    public init(title: String, description: String, actionTitle: String, action: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(title)
                .atlasFont(.headline)
                .foregroundColor(.red)
            
            Text(description)
                .atlasFont(.subheadline)
                .foregroundColor(Color.Atlas.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                AppearanceManager.shared.triggerHaptic(style: .heavy)
                action()
            }) {
                Text(actionTitle)
                    .atlasFont(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                .background(Color.red.opacity(0.05).cornerRadius(12))
        )
    }
}
