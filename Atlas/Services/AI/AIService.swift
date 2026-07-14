import Foundation
import SwiftData
import UIKit

/// Coordination layer between AIEngine and the rest of the app.
/// Wraps all AI calls with error handling, toggle checks, and Result-based returns.
public class AIService {
    public static let shared = AIService()
    
    private init() {}
    
    // MARK: - Error Type
    
    public enum AIServiceError: LocalizedError {
        case featureDisabled(String)
        case providerNotConfigured
        case networkUnavailable
        case aiError(String)
        case unknown(Error)
        
        public var errorDescription: String? {
            switch self {
            case .featureDisabled(let feature):
                return "\(feature) is disabled. Enable it in Settings → Atlas Intelligence."
            case .providerNotConfigured:
                return "AI provider is not configured. Please add your API key in Settings."
            case .networkUnavailable:
                return "No network connection. Please try again when online."
            case .aiError(let message):
                return message
            case .unknown(let error):
                return error.localizedDescription
            }
        }
    }
    
    // MARK: - Safe Wrappers
    
    public func fetchDailyInsights(context: ModelContext) async -> Result<[DailyInsight], AIServiceError> {
        guard AIConfiguration.shared.enableAICoaching else {
            return .failure(.featureDisabled("AI Coaching"))
        }
        
        do {
            let insights = try await AIEngine.shared.fetchDailyInsights(context: context)
            return .success(insights)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func recognizeMeal(from image: UIImage) async -> Result<[AIFoodItem], AIServiceError> {
        guard AIConfiguration.shared.enableMealRecognition else {
            return .failure(.featureDisabled("Meal Recognition"))
        }
        
        do {
            let items = try await AIEngine.shared.recognizeMeal(from: image)
            return .success(items)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchWorkoutRecommendations(context: ModelContext) async -> Result<[WorkoutRecommendation], AIServiceError> {
        guard AIConfiguration.shared.enableAICoaching else {
            return .failure(.featureDisabled("Workout Coaching"))
        }
        
        do {
            let recs = try await AIEngine.shared.fetchWorkoutRecommendations(context: context)
            return .success(recs)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchNutritionRecommendations(context: ModelContext) async -> Result<[NutritionRecommendation], AIServiceError> {
        guard AIConfiguration.shared.enableAICoaching else {
            return .failure(.featureDisabled("Nutrition Coaching"))
        }
        
        do {
            let recs = try await AIEngine.shared.fetchNutritionRecommendations(context: context)
            return .success(recs)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func fetchRecoveryRecommendations(context: ModelContext) async -> Result<[RecoveryRecommendation], AIServiceError> {
        guard AIConfiguration.shared.enableAICoaching else {
            return .failure(.featureDisabled("Recovery Coaching"))
        }
        
        do {
            let recs = try await AIEngine.shared.fetchRecoveryRecommendations(context: context)
            return .success(recs)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func generateWeeklyReport(context: ModelContext) async -> Result<WeeklyReportData, AIServiceError> {
        guard AIConfiguration.shared.enableWeeklyReports else {
            return .failure(.featureDisabled("Weekly Reports"))
        }
        
        do {
            let report = try await AIEngine.shared.generateWeeklyReport(context: context)
            return .success(report)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func generateRecipes(
        ingredients: [String],
        goal: String,
        targetCalories: Int,
        targetProtein: Int
    ) async -> Result<[RecipeSuggestion], AIServiceError> {
        do {
            let recipes = try await AIEngine.shared.generateRecipes(
                ingredients: ingredients,
                goal: goal,
                targetCalories: targetCalories,
                targetProtein: targetProtein
            )
            return .success(recipes)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    public func generateMealPlan(days: Int, context: ModelContext) async -> Result<[MealPlanDay], AIServiceError> {
        do {
            let plan = try await AIEngine.shared.generateMealPlan(days: days, context: context)
            return .success(plan)
        } catch {
            return .failure(mapError(error))
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapError(_ error: Error) -> AIServiceError {
        if let providerError = error as? AIProviderError {
            switch providerError {
            case .invalidConfiguration:
                return .providerNotConfigured
            case .networkError:
                return .networkUnavailable
            case .rateLimitExceeded:
                return .aiError("Rate limit reached. Please wait a moment.")
            case .featureDisabled:
                return .featureDisabled("AI Feature")
            case .apiError, .invalidResponse:
                return .aiError(providerError.localizedDescription)
            }
        }
        
        // Check for URLSession errors
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .networkUnavailable
        }
        
        return .unknown(error)
    }
}
