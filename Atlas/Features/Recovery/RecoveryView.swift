import SwiftUI

public struct RecoveryView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.large) {
                    CustomNavigationBar(title: "Recovery")
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            HStack {
                                Text("RECOVERY SCORE")
                                    .atlasFont(AtlasTypography.caption(weight: .bold))
                                    .foregroundColor(Color.Atlas.textSecondary)
                                Spacer()
                                Image(systemName: "heart.text.square.fill")
                                    .foregroundColor(.cyan)
                            }
                            
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("84")
                                    .atlasFont(.system(size: 64, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.Atlas.textPrimary)
                                Text("/ 100")
                                    .atlasFont(AtlasTypography.title3())
                                    .foregroundColor(Color.Atlas.textTertiary)
                            }
                            
                            Text("Your body is well rested. It's a great day to push your limits.")
                                .atlasFont(AtlasTypography.body())
                                .foregroundColor(Color.Atlas.textSecondary)
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    
                    // Sleep metric
                    MetricCard(title: "Sleep Quality", value: "Optimal", unit: "", icon: "moon.stars.fill", color: .cyan)
                        .padding(.horizontal, Spacing.medium)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    RecoveryView()
}
