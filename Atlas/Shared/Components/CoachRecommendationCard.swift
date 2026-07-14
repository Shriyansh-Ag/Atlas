import SwiftUI

/// Reusable card for AI coaching recommendations (workout, nutrition, recovery).
public struct CoachRecommendationCard: View {
    public let icon: String
    public let iconColor: Color
    public let title: String
    public let message: String
    public let detail: String?
    public var confidence: Double?
    public var actionTitle: String?
    public var action: (() -> Void)?
    
    public init(
        icon: String,
        iconColor: Color,
        title: String,
        message: String,
        detail: String? = nil,
        confidence: Double? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.message = message
        self.detail = detail
        self.confidence = confidence
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(alignment: .top, spacing: Spacing.small) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(title)
                                .atlasFont(AtlasTypography.headline())
                                .foregroundColor(Color.Atlas.textPrimary)
                            
                            Spacer()
                            
                            if let confidence = confidence {
                                HStack(spacing: 2) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 10))
                                    Text("\(Int(confidence * 100))%")
                                        .font(.caption2.bold())
                                }
                                .foregroundColor(confidence > 0.8 ? .green : .orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill((confidence > 0.8 ? Color.green : Color.orange).opacity(0.15))
                                )
                            }
                        }
                        
                        Text(message)
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if let detail = detail {
                            Text(detail)
                                .atlasFont(AtlasTypography.caption())
                                .foregroundColor(Color.Atlas.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 2)
                        }
                    }
                }
                
                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        Text(actionTitle)
                            .atlasFont(AtlasTypography.caption(weight: .semibold))
                            .foregroundColor(Color.Atlas.primary)
                            .padding(.horizontal, Spacing.medium)
                            .padding(.vertical, Spacing.xSmall)
                            .background(
                                Capsule()
                                    .fill(Color.Atlas.primary.opacity(0.15))
                            )
                    }
                    .padding(.leading, 52) // Align with text after icon
                }
            }
        }
    }
}
