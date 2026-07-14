import SwiftUI

public struct MacroProgressCard: View {
    public let title: String
    public let current: Double
    public let target: Double
    public let unit: String
    public let color: Color
    
    public init(title: String, current: Double, target: Double, unit: String, color: Color) {
        self.title = title
        self.current = current
        self.target = target
        self.unit = unit
        self.color = color
    }
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text(title)
                        .atlasFont(AtlasTypography.callout())
                        .foregroundColor(Color.Atlas.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 4)
                    Text("\(Int(current)) / \(Int(target)) \(unit)")
                        .atlasFont(AtlasTypography.footnote(weight: .medium))
                        .foregroundColor(Color.Atlas.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.Atlas.surface)
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color)
                            .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 12)
                            .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 12)
            }
        }
    }
}
