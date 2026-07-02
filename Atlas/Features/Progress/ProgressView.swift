import SwiftUI

public struct ProgressView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.large) {
                    CustomNavigationBar(title: "Progress")
                    
                    EmptyState(
                        title: "No Data Yet",
                        description: "Complete your first workout or log a meal to see your progress trends over time.",
                        icon: "chart.xyaxis.line",
                        actionTitle: "Explore Workouts",
                        action: {}
                    )
                    .padding(.top, Spacing.xxLarge)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ProgressView()
}
