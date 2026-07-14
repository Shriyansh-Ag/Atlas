import Foundation
import SwiftData

/// Analyzes nutrition patterns and provides AI-powered dietary recommendations.
public class NutritionRecommendationEngine {
    public static let shared = NutritionRecommendationEngine()
    
    private init() {}
    
    public func generateRecommendations(context: ModelContext) async throws -> [NutritionRecommendation] {
        guard AIConfiguration.shared.enableAICoaching else { return [] }
        
        let provider = AIConfiguration.shared.getProvider()
        let nutritionString = buildNutritionString(context: context)
        let goalsString = buildGoalsString(context: context)
        
        let prompt = PromptBuilder.buildNutritionCoachPrompt(nutrition: nutritionString, goals: goalsString)
        let jsonString = try await provider.generateJSON(prompt: prompt)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([NutritionRecommendation].self, from: data)
        } catch {
            throw AIProviderError.apiError("Failed to parse nutrition recommendations: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private
    
    private func buildNutritionString(context: ModelContext) -> String {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<MealLog>(
            predicate: #Predicate { $0.date >= sevenDaysAgo },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        guard let logs = try? context.fetch(descriptor) else {
            return "No nutrition data available."
        }
        
        if logs.isEmpty {
            return "No meals logged in the past 7 days."
        }
        
        // Group by day
        var dailyTotals: [(String, Double, Double, Double, Double)] = [] // (date, cal, pro, carb, fat)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let grouped = Dictionary(grouping: logs) { log in
            calendar.startOfDay(for: log.date)
        }
        
        for (day, dayLogs) in grouped.sorted(by: { $0.key > $1.key }) {
            var totalCal = 0.0, totalPro = 0.0, totalCarb = 0.0, totalFat = 0.0
            for log in dayLogs {
                let macros = NutritionCalculator.totalMacros(for: log.items)
                totalCal += macros.calories
                totalPro += macros.protein
                totalCarb += macros.carbs
                totalFat += macros.fat
            }
            dailyTotals.append((dateFormatter.string(from: day), totalCal, totalPro, totalCarb, totalFat))
        }
        
        var summary = "Nutrition Log (last 7 days):\n"
        for (date, cal, pro, carb, fat) in dailyTotals {
            summary += "[\(date)] \(Int(cal)) kcal | P: \(Int(pro))g | C: \(Int(carb))g | F: \(Int(fat))g\n"
        }
        
        // Add meal count per day
        summary += "\nMeals per day: \(logs.count / max(1, grouped.count))\n"
        
        return summary
    }
    
    private func buildGoalsString(context: ModelContext) -> String {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? context.fetch(descriptor).first else {
            return "No profile data available."
        }
        
        return """
        Goal: \(profile.fitnessGoal.rawValue)
        Daily Calories Target: \(Int(profile.dailyCalories)) kcal
        Protein Target: \(Int(profile.targetProteinGram))g
        Carbs Target: \(Int(profile.targetCarbsGram))g
        Fat Target: \(Int(profile.targetFatGram))g
        Dietary Preferences: \(profile.dietaryPreferences.map(\.rawValue).joined(separator: ", "))
        Allergies: \(profile.allergies.map(\.rawValue).joined(separator: ", "))
        """
    }
}
