import SwiftUI

public struct SectionHeader: View {
    public let title: String
    public let actionTitle: String?
    public let action: (() -> Void)?
    
    public init(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        HStack {
            Text(title.uppercased())
                .atlasFont(AtlasTypography.caption(weight: .bold))
                .foregroundColor(Color.Atlas.textSecondary)
                .tracking(1.5)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .atlasFont(AtlasTypography.footnote(weight: .medium))
                        .foregroundColor(Color.Atlas.primary)
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.small)
    }
}
