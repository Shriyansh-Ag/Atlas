import SwiftUI
import WidgetKit

@main
struct AtlasWidgetsBundle: WidgetBundle {
    var body: some Widget {
        // Home Screen
        CaloriesWidget()
        WorkoutWidget()
        HealthWidget()
        DashboardWidget()
        StreakWidget()
        
        // Interactive
        WaterWidget()
        QuickActionsWidget()
        
        // Lock Screen
        LockScreenCaloriesWidget()
        LockScreenStepsWidget()
        LockScreenProteinWidget()
        LockScreenStreakWidget()
        
        // Live Activity
        WorkoutLiveActivity()
    }
}
