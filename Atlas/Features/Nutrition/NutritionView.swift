import SwiftUI

public struct NutritionView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.large) {
                    CustomNavigationBar(title: "Nutrition")
                    
                    // Macro Summary
                    GlassCard {
                        VStack(spacing: Spacing.medium) {
                            HStack {
                                Text("Macronutrients")
                                    .atlasFont(AtlasTypography.title3())
                                    .foregroundColor(Color.Atlas.textPrimary)
                                Spacer()
                                Text("1,240 / 2,400 kcal")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(Color.Atlas.textSecondary)
                            }
                            
                            HStack(spacing: Spacing.medium) {
                                MacroIndicator(title: "Protein", current: 85, target: 160, color: .red)
                                MacroIndicator(title: "Carbs", current: 120, target: 250, color: .blue)
                                MacroIndicator(title: "Fats", current: 40, target: 70, color: .orange)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    
                    EmptyState(
                        title: "Log Your Meals",
                        description: "Track your food intake to see your daily breakdown and hit your goals.",
                        icon: "fork.knife",
                        actionTitle: "Log Meal",
                        action: {}
                    )
                    .padding(.top, Spacing.large)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct MacroIndicator: View {
    let title: String
    let current: Int
    let target: Int
    let color: Color
    
    var progress: Double {
        Double(current) / Double(target)
    }
    
    var body: some View {
        VStack(spacing: Spacing.xSmall) {
            ProgressRing(progress: progress, color: color, thickness: 6, size: 60)
            
            VStack(spacing: 2) {
                Text(title)
                    .atlasFont(AtlasTypography.caption(weight: .semibold))
                    .foregroundColor(Color.Atlas.textSecondary)
                Text("\(current)g")
                    .atlasFont(AtlasTypography.subheadline(weight: .bold))
                    .foregroundColor(Color.Atlas.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NutritionView()
}
