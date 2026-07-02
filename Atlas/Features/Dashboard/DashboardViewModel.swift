import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
public class DashboardViewModel: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var healthSnapshot: HealthSnapshot = HealthSnapshot()
    @Published public var macroData: MacroData = MacroData()
    @Published public var todaysWorkout: WorkoutSummary? = nil
    @Published public var streakData: StreakData = StreakData()
    @Published public var caloriesConsumed: Double = 0
    @Published public var caloriesTarget: Double = 2400
    @Published public var errorMessage: String? = nil
    
    public init() {
        // Initialize with empty or default data
    }
    
    public func update(with metrics: [CachedHealthMetric]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        // Create a dictionary for quick lookup by type
        var metricDict = [HealthMetricType: Double]()
        for metric in metrics {
            if metric.id.hasSuffix(todayString) {
                metricDict[metric.type] = metric.value
            }
        }
        
        self.healthSnapshot = HealthSnapshot(
            sleepScore: Int((metricDict[.sleepScore] ?? 0).rounded()),
            steps: Int(metricDict[.steps] ?? 0),
            heartRate: Int(metricDict[.heartRate] ?? 0),
            vo2Max: metricDict[.vo2Max] ?? 0,
            restingHeartRate: Int(metricDict[.restingHeartRate] ?? 0),
            waterIntakeLiters: metricDict[.waterIntake] ?? 0,
            waterTargetLiters: 3.0,
            bodyWeightKg: metricDict[.weight] ?? 0,
            bodyFatPercentage: metricDict[.bodyFatPercentage]
        )
        
        // Mocking macros for now since HealthKit doesn't easily track granular dietary macros without a dedicated service
        self.macroData = MacroData(proteinConsumed: 120, proteinTarget: 160, carbsConsumed: 180, carbsTarget: 220, fatConsumed: 45, fatTarget: 65)
        
        // Calories
        self.caloriesConsumed = metricDict[.activeEnergyBurned] ?? (metricDict[.basalEnergyBurned] ?? 1540)
        
        // Streak (mocked for now)
        self.streakData = StreakData(currentStreak: 12, longestStreak: 21, completedDaysThisWeek: [1, 2, 4, 5])
        
        // Workout (mocked for now)
        self.todaysWorkout = WorkoutSummary(name: "Upper Body Strength", durationMinutes: 45, muscleGroups: ["Chest", "Back", "Arms"], exerciseCount: 6, isCompleted: false)
    }
    
    // MARK: - Computed Properties
    
    public var caloriesRemaining: Double {
        return max(0, caloriesTarget - caloriesConsumed)
    }
    
    public var calorieProgress: Double {
        guard caloriesTarget > 0 else { return 0 }
        return caloriesConsumed / caloriesTarget
    }
    
    public var proteinRemaining: Double {
        return max(0, macroData.proteinTarget - macroData.proteinConsumed)
    }
    
    public var motivationalMessage: String {
        if let workout = todaysWorkout, workout.isCompleted {
            return "Workout completed. Great job."
        } else if proteinRemaining > 0 && proteinRemaining < 40 {
            return "Only \(Int(proteinRemaining))g protein left."
        } else if calorieProgress > 0.8 && calorieProgress <= 1.0 {
            return "You're right on track today."
        } else if streakData.currentStreak > 3 {
            return "Consistency beats perfection."
        } else {
            return "Let's make today count."
        }
    }
}
