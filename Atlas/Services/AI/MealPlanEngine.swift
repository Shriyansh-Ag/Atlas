import Foundation
import SwiftData

/// Generates AI-powered meal plans respecting dietary preferences, allergies, and macro targets.
public class MealPlanEngine {
    public static let shared = MealPlanEngine()
    
    private init() {}
    
    public func generateMealPlan(days: Int, context: ModelContext) async throws -> [MealPlanDay] {
        let provider = AIConfiguration.shared.getProvider()
        
        // Fetch user profile for preferences
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profile = try? context.fetch(profileDescriptor).first
        
        let preferences = profile?.dietaryPreferences.map(\.rawValue).joined(separator: ", ") ?? "None"
        let allergies = profile?.allergies.map(\.rawValue).joined(separator: ", ") ?? "None"
        let targets = """
        Calories: \(Int(profile?.dailyCalories ?? 2400)) kcal
        Protein: \(Int(profile?.targetProteinGram ?? 160))g
        Carbs: \(Int(profile?.targetCarbsGram ?? 250))g
        Fat: \(Int(profile?.targetFatGram ?? 70))g
        """
        
        let prompt = PromptBuilder.buildMealPlanPrompt(
            days: days,
            preferences: preferences,
            allergies: allergies,
            targets: targets
        )
        
        let jsonString = try await provider.generateJSON(prompt: prompt)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([MealPlanDay].self, from: data)
        } catch {
            throw AIProviderError.apiError("Failed to parse meal plan: \(error.localizedDescription)")
        }
    }
}
