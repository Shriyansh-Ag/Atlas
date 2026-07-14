import Foundation
import SwiftUI
import SwiftData
import Combine
import HealthKit
import WidgetKit

@MainActor
public class DashboardViewModel: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var healthSnapshot: HealthSnapshot = HealthSnapshot()
    @Published public var macroData: MacroData = MacroData()
    @Published public var importedWorkouts: [HKWorkout] = []
    @Published public var dailyInsights: [DailyInsight] = []
    @Published public var workoutRecommendations: [WorkoutRecommendation] = []
    @Published public var nutritionRecommendations: [NutritionRecommendation] = []
    @Published public var streakData: StreakData = StreakData()
    @Published public var caloriesConsumed: Double = 0
    @Published public var caloriesTarget: Double = 2400
    @Published public var errorMessage: String? = nil
    
    public init() {
        // Initialize with empty or default data
    }
    
    public func update(with metrics: [CachedHealthMetric], context: ModelContext) {
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
        
        // Streak is computed dynamically now
        let currentStreak = calculateStreak(workouts: importedWorkouts)
        self.streakData = StreakData(currentStreak: currentStreak, longestStreak: max(currentStreak, streakData.longestStreak), completedDaysThisWeek: completedDaysThisWeek(workouts: importedWorkouts))
        
        // Updates
        updateNutrition(context: context)
        updateWorkout(context: context)
        syncWidgetSnapshot()
        
        Task {
            await fetchInsights(context: context)
        }
    }
    
    /// Write current state to the App Group container for widgets.
    private func syncWidgetSnapshot() {
        let snapshot = SharedDataSnapshot(
            caloriesConsumed: caloriesConsumed,
            caloriesTarget: caloriesTarget,
            proteinConsumed: macroData.proteinConsumed,
            proteinTarget: macroData.proteinTarget,
            carbsConsumed: macroData.carbsConsumed,
            carbsTarget: macroData.carbsTarget,
            fatConsumed: macroData.fatConsumed,
            fatTarget: macroData.fatTarget,
            steps: healthSnapshot.steps,
            sleepScore: healthSnapshot.sleepScore,
            recoveryScore: 0, // ponytail: recovery score computed elsewhere, wire later
            waterIntake: healthSnapshot.waterIntakeLiters,
            waterTarget: healthSnapshot.waterTargetLiters,
            bodyWeight: healthSnapshot.bodyWeightKg,
            restingHeartRate: healthSnapshot.restingHeartRate,
            vo2Max: healthSnapshot.vo2Max,
            todayWorkoutCalories: importedWorkouts.reduce(0) { $0 + ($1.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0) },
            todayWorkoutMinutes: Int(importedWorkouts.reduce(0) { $0 + $1.duration } / 60),
            currentStreak: streakData.currentStreak
        )
        SharedDataStore.saveAndReload(snapshot)
    }
    
    private func fetchInsights(context: ModelContext) async {
        let package = await AIEngine.shared.fetchDailyCoachingPackage(context: context)
        await MainActor.run {
            self.dailyInsights = package.insights
            self.workoutRecommendations = package.workoutRecommendations
            self.nutritionRecommendations = package.nutritionRecommendations
        }
    }
    
    private func updateNutrition(context: ModelContext) {
        DailyNutritionManager.shared.update(with: context)
        
        self.macroData = MacroData(
            proteinConsumed: DailyNutritionManager.shared.proteinConsumed,
            proteinTarget: DailyNutritionManager.shared.proteinTarget,
            carbsConsumed: DailyNutritionManager.shared.carbsConsumed,
            carbsTarget: DailyNutritionManager.shared.carbsTarget,
            fatConsumed: DailyNutritionManager.shared.fatConsumed,
            fatTarget: DailyNutritionManager.shared.fatTarget
        )
        self.caloriesConsumed = DailyNutritionManager.shared.caloriesConsumed
        self.caloriesTarget = DailyNutritionManager.shared.caloriesTarget
    }
    
    private func updateWorkout(context: ModelContext) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        Task {
            do {
                let repo = HealthSampleRepository()
                let workouts = try await repo.fetchWorkouts(from: startOfDay, to: Date())
                await MainActor.run {
                    self.importedWorkouts = workouts
                }
            } catch {
                print("Failed to fetch HealthKit workouts for dashboard: \(error)")
            }
        }
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
        if !importedWorkouts.isEmpty {
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
    
    // MARK: - Helpers
    
    private func calculateStreak(workouts: [HKWorkout]) -> Int {
        // Simplified dynamic streak logic for UI (count distinct days with workouts in the past N days)
        guard !workouts.isEmpty else { return 0 }
        return workouts.count > 0 ? 1 : 0 // Real logic would iterate through days. Defaulting to 1 if active today.
    }
    
    private func completedDaysThisWeek(workouts: [HKWorkout]) -> Set<Int> {
        let calendar = Calendar.current
        return Set(workouts.map { calendar.component(.weekday, from: $0.startDate) })
    }
}
