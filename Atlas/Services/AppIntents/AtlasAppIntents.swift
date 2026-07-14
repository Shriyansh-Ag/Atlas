import AppIntents
import SwiftUI

// 👱‍♀️ ponytail: AppIntents are declarative structs. No manager needed.

// MARK: - Navigation Intents

struct OpenDashboardIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Dashboard"
    static var description = IntentDescription("Opens Atlas to the dashboard.")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct OpenNutritionIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Nutrition"
    static var description = IntentDescription("Opens Atlas to nutrition tracking.")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct OpenProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Progress"
    static var description = IntentDescription("Opens Atlas to your progress.")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct OpenGoalsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Goals"
    static var description = IntentDescription("Opens Atlas to your goals.")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct StartWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Workout"
    static var description = IntentDescription("Opens Atlas to start a workout.")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// MARK: - Action Intents

struct LogWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Water"
    static var description = IntentDescription("Log water intake in Atlas.")
    
    @Parameter(title: "Amount (ml)", default: 250)
    var amountML: Int
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let totalML = await MainActor.run {
            var snapshot = SharedDataStore.load()
            let liters = Double(amountML) / 1000.0
            snapshot.waterIntake += liters
            snapshot.lastUpdated = Date()
            SharedDataStore.saveAndReload(snapshot)
            return Int(snapshot.waterIntake * 1000)
        }
        
        return .result(dialog: "Logged \(amountML)ml. Total today: \(totalML)ml.")
    }
}

struct ShowCaloriesIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Today's Calories"
    static var description = IntentDescription("Shows your calorie intake for today.")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let (consumed, remaining) = await MainActor.run {
            let snapshot = SharedDataStore.load()
            return (Int(snapshot.caloriesConsumed), Int(snapshot.caloriesRemaining))
        }
        return .result(dialog: "You've consumed \(consumed) kcal. \(remaining) kcal remaining.")
    }
}

struct LogWeightIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Weight"
    static var description = IntentDescription("Opens Atlas to log your weight.")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct LogMealIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Meal"
    static var description = IntentDescription("Opens Atlas to log a meal.")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
