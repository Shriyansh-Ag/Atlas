import Foundation
import SwiftData
import UIKit

/// Central façade for all Atlas Intelligence features.
/// All AI interactions should go through this class.
public class AIEngine {
    public static let shared = AIEngine()
    
    private init() {}
    
    // MARK: - Daily Insights
    
    public func fetchDailyInsights(context: ModelContext) async throws -> [DailyInsight] {
        return try await InsightEngine.shared.generateDailyInsights(context: context)
    }
    
    // MARK: - Meal Recognition
    
    public func recognizeMeal(from image: UIImage) async throws -> [AIFoodItem] {
        return try await MealRecognitionService.shared.recognizeMeal(from: image)
    }
    
    // MARK: - Coaching Recommendations
    
    public func fetchWorkoutRecommendations(context: ModelContext) async throws -> [WorkoutRecommendation] {
        return try await WorkoutRecommendationEngine.shared.generateRecommendations(context: context)
    }
    
    public func fetchNutritionRecommendations(context: ModelContext) async throws -> [NutritionRecommendation] {
        return try await NutritionRecommendationEngine.shared.generateRecommendations(context: context)
    }
    
    public func fetchRecoveryRecommendations(context: ModelContext) async throws -> [RecoveryRecommendation] {
        return try await RecoveryRecommendationEngine.shared.generateRecommendations(context: context)
    }
    
    // MARK: - Daily Coaching Package
    
    public func fetchDailyCoachingPackage(context: ModelContext) async -> DailySummaryGenerator.DailyCoachingPackage {
        return await DailySummaryGenerator.shared.getCoachingPackage(context: context)
    }
    
    public func refreshDailyCoachingPackage(context: ModelContext) async -> DailySummaryGenerator.DailyCoachingPackage {
        return await DailySummaryGenerator.shared.refresh(context: context)
    }
    
    // MARK: - Weekly Report
    
    public func generateWeeklyReport(context: ModelContext) async throws -> WeeklyReportData {
        return try await WeeklyReportGenerator.shared.generateReport(context: context)
    }
    
    // MARK: - Recipe Builder
    
    public func generateRecipes(
        ingredients: [String],
        goal: String,
        targetCalories: Int,
        targetProtein: Int
    ) async throws -> [RecipeSuggestion] {
        return try await RecipeEngine.shared.generateRecipes(
            ingredients: ingredients,
            goal: goal,
            targetCalories: targetCalories,
            targetProtein: targetProtein
        )
    }
    
    // MARK: - Meal Planner
    
    public func generateMealPlan(days: Int, context: ModelContext) async throws -> [MealPlanDay] {
        return try await MealPlanEngine.shared.generateMealPlan(days: days, context: context)
    }
    
    // MARK: - Food Correction (Local Learning)
    
    public func correctMealItem(
        original: AIFoodItem,
        corrected: AIFoodItem,
        context: ModelContext
    ) {
        let correction = AIFoodCorrection(
            originalName: original.name,
            correctedName: corrected.name,
            originalCalories: original.calories,
            correctedCalories: corrected.calories,
            correctedProtein: corrected.protein,
            correctedCarbs: corrected.carbs,
            correctedFat: corrected.fat
        )
        context.insert(correction)
        try? context.save()
    }
}
