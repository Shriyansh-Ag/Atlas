import SwiftUI

public struct InsightCard: View {
    public let insight: DailyInsight
    
    public init(insight: DailyInsight) {
        self.insight = insight
    }
    
    public var body: some View {
        GlassCard {
            HStack(alignment: .top, spacing: Spacing.medium) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(insight.title)
                        .atlasFont(AtlasTypography.headline())
                        .foregroundColor(Color.Atlas.textPrimary)
                    
                    Text(insight.message)
                        .atlasFont(AtlasTypography.subheadline())
                        .foregroundColor(Color.Atlas.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
        }
    }
    
    private var iconName: String {
        switch insight.category {
        case .nutrition: return "fork.knife.circle.fill"
        case .workout: return "dumbbell.fill"
        case .recovery: return "moon.zzz.fill"
        case .general: return "sparkles"
        }
    }
    
    private var iconColor: Color {
        switch insight.category {
        case .nutrition: return .orange
        case .workout: return .purple
        case .recovery: return .indigo
        case .general: return .blue
        }
    }
}
