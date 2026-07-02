import SwiftUI

public struct WorkoutView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.large) {
                    CustomNavigationBar(title: "Workouts")
                    
                    HStack {
                        SecondaryButton(title: "Programs", icon: "list.bullet.clipboard", action: {})
                        SecondaryButton(title: "History", icon: "clock.arrow.circlepath", action: {})
                    }
                    .padding(.horizontal, Spacing.medium)
                    
                    // Featured Workout
                    GlassCard {
                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            HStack {
                                Text("FEATURED")
                                    .atlasFont(AtlasTypography.caption(weight: .bold))
                                    .foregroundColor(Color.Atlas.accent)
                                Spacer()
                                Text("45 MIN")
                                    .atlasFont(AtlasTypography.caption(weight: .bold))
                                    .foregroundColor(Color.Atlas.textSecondary)
                            }
                            
                            Text("Full Body Power")
                                .atlasFont(AtlasTypography.title2())
                                .foregroundColor(Color.Atlas.textPrimary)
                            
                            Text("Build strength and endurance with this comprehensive full body routine.")
                                .atlasFont(AtlasTypography.body())
                                .foregroundColor(Color.Atlas.textSecondary)
                            
                            PrimaryButton(title: "Start Workout", icon: "play.fill", action: {})
                                .padding(.top, Spacing.small)
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    WorkoutView()
}
