import SwiftUI

public struct EmptyState: View {
    let title: String
    let description: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(title: String, description: String, icon: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(Color.Atlas.secondary)
            
            VStack(spacing: Spacing.xSmall) {
                Text(title)
                    .atlasFont(AtlasTypography.title2())
                    .foregroundColor(Color.Atlas.textPrimary)
                
                Text(description)
                    .atlasFont(AtlasTypography.body())
                    .foregroundColor(Color.Atlas.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.large)
            
            if let actionTitle = actionTitle, let action = action {
                SecondaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, Spacing.xxLarge)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Atlas.background)
    }
}
