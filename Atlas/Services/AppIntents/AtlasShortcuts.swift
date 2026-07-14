import AppIntents

// 👱‍♀️ ponytail: AppShortcutsProvider registers Siri phrases. That's it.

struct AtlasShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenDashboardIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Open \(.applicationName) dashboard",
                "Show \(.applicationName)"
            ],
            shortTitle: "Open Dashboard",
            systemImageName: "house"
        )
        
        AppShortcut(
            intent: StartWorkoutIntent(),
            phrases: [
                "Start today's workout in \(.applicationName)",
                "Start workout in \(.applicationName)",
                "Begin workout in \(.applicationName)"
            ],
            shortTitle: "Start Workout",
            systemImageName: "dumbbell"
        )
        
        AppShortcut(
            intent: LogWaterIntent(),
            phrases: [
                "Log water in \(.applicationName)",
                "Add water in \(.applicationName)"
            ],
            shortTitle: "Log Water",
            systemImageName: "drop.fill"
        )
        
        AppShortcut(
            intent: ShowCaloriesIntent(),
            phrases: [
                "Show today's calories in \(.applicationName)",
                "How many calories in \(.applicationName)",
                "Calories remaining in \(.applicationName)"
            ],
            shortTitle: "Today's Calories",
            systemImageName: "flame"
        )
        
        AppShortcut(
            intent: LogMealIntent(),
            phrases: [
                "Log meal in \(.applicationName)",
                "Log breakfast in \(.applicationName)",
                "Log lunch in \(.applicationName)"
            ],
            shortTitle: "Log Meal",
            systemImageName: "fork.knife"
        )
        
        AppShortcut(
            intent: OpenGoalsIntent(),
            phrases: [
                "Show goals in \(.applicationName)",
                "Open goals in \(.applicationName)"
            ],
            shortTitle: "Open Goals",
            systemImageName: "target"
        )
    }
}
