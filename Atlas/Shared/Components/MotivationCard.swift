import SwiftUI

public struct MotivationCard: View {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        GlassCard {
            HStack(spacing: Spacing.medium) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.Atlas.primary)
                    .symbolEffect(.pulse, options: .repeating)
                
                Text(message)
                    .atlasFont(AtlasTypography.callout(weight: .medium))
                    .foregroundColor(Color.Atlas.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
}
