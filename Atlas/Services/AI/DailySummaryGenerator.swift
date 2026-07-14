import Foundation
import SwiftData

/// Coordinates all coaching engines to produce a unified daily coaching package.
/// Caches results for the current day to avoid redundant API calls.
public class DailySummaryGenerator {
    public static let shared = DailySummaryGenerator()
    
    /// Cached daily coaching data
    public struct DailyCoachingPackage {
        public var insights: [DailyInsight]
        public var workoutRecommendations: [WorkoutRecommendation]
        public var nutritionRecommendations: [NutritionRecommendation]
        public var recoveryRecommendations: [RecoveryRecommendation]
        public var generatedDate: Date
        
        public static let empty = DailyCoachingPackage(
            insights: [],
            workoutRecommendations: [],
            nutritionRecommendations: [],
            recoveryRecommendations: [],
            generatedDate: .distantPast
        )
    }
    
    private var cachedPackage: DailyCoachingPackage = .empty
    
    private init() {}
    
    /// Returns the cached coaching package if it was generated today, otherwise generates fresh.
    public func getCoachingPackage(context: ModelContext) async -> DailyCoachingPackage {
        let calendar = Calendar.current
        if calendar.isDateInToday(cachedPackage.generatedDate) {
            return cachedPackage
        }
        
        return await generateFresh(context: context)
    }
    
    /// Forces a fresh generation, bypassing the cache.
    public func refresh(context: ModelContext) async -> DailyCoachingPackage {
        return await generateFresh(context: context)
    }
    
    // MARK: - Private
    
    private func generateFresh(context: ModelContext) async -> DailyCoachingPackage {
        async let insightsTask = fetchInsights(context: context)
        async let workoutTask = fetchWorkoutRecs(context: context)
        async let nutritionTask = fetchNutritionRecs(context: context)
        async let recoveryTask = fetchRecoveryRecs(context: context)
        
        let insights = await insightsTask
        let workoutRecs = await workoutTask
        let nutritionRecs = await nutritionTask
        let recoveryRecs = await recoveryTask
        
        let package = DailyCoachingPackage(
            insights: insights,
            workoutRecommendations: workoutRecs,
            nutritionRecommendations: nutritionRecs,
            recoveryRecommendations: recoveryRecs,
            generatedDate: Date()
        )
        
        self.cachedPackage = package
        return package
    }
    
    private func fetchInsights(context: ModelContext) async -> [DailyInsight] {
        do {
            return try await InsightEngine.shared.generateDailyInsights(context: context)
        } catch {
            print("⚠️ DailySummary: Failed to fetch insights: \(error)")
            return []
        }
    }
    
    private func fetchWorkoutRecs(context: ModelContext) async -> [WorkoutRecommendation] {
        do {
            return try await WorkoutRecommendationEngine.shared.generateRecommendations(context: context)
        } catch {
            print("⚠️ DailySummary: Failed to fetch workout recs: \(error)")
            return []
        }
    }
    
    private func fetchNutritionRecs(context: ModelContext) async -> [NutritionRecommendation] {
        do {
            return try await NutritionRecommendationEngine.shared.generateRecommendations(context: context)
        } catch {
            print("⚠️ DailySummary: Failed to fetch nutrition recs: \(error)")
            return []
        }
    }
    
    private func fetchRecoveryRecs(context: ModelContext) async -> [RecoveryRecommendation] {
        do {
            return try await RecoveryRecommendationEngine.shared.generateRecommendations(context: context)
        } catch {
            print("⚠️ DailySummary: Failed to fetch recovery recs: \(error)")
            return []
        }
    }
}
