import SwiftUI

public struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    public init(title: String, value: String, unit: String, icon: String, color: Color = Color.Atlas.primary) {
        self.title = title
        self.value = value
        self.unit = unit
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        GlassCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    HStack(spacing: Spacing.xSmall) {
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 14, weight: .bold))
                        Text(title.uppercased())
                            .atlasFont(AtlasTypography.caption(weight: .bold))
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(value)
                            .atlasFont(AtlasTypography.largeTitle(weight: .bold))
                            .foregroundColor(Color.Atlas.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text(unit)
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(Color.Atlas.textTertiary)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.Atlas.background.ignoresSafeArea()
        HStack {
            MetricCard(title: "Calories", value: "2,450", unit: "kcal", icon: "flame.fill", color: .orange)
            MetricCard(title: "Steps", value: "12k", unit: "steps", icon: "figure.walk", color: .blue)
        }
        .padding()
    }
}
