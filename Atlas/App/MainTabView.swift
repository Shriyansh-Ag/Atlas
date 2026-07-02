import SwiftUI

public struct MainTabView: View {
    @Environment(\.appEnvironment) private var environment
    @State private var selectedTab: Route = .dashboard
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(Route.dashboard)
            
            WorkoutView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
                .tag(Route.workout)
            
            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
                .tag(Route.nutrition)
            
            RecoveryView()
                .tabItem {
                    Label("Recovery", systemImage: "heart.text.square.fill")
                }
                .tag(Route.recovery)
            
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.xyaxis.line")
                }
                .tag(Route.progress)
        }
        .tint(Color.Atlas.primary)
        // Customizing tab bar appearance for iOS 15+ 
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.Atlas.background)
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.Atlas.secondary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.Atlas.secondary)]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
