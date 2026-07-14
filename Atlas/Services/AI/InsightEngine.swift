import Foundation
import SwiftData

public class InsightEngine {
    public static let shared = InsightEngine()
    
    private init() {}
    
    public func generateDailyInsights(context: ModelContext) async throws -> [DailyInsight] {
        guard AIConfiguration.shared.enableAICoaching else { return [] }
        
        let provider = AIConfiguration.shared.getProvider()
        let userMetricsString = buildRealMetricsString(context: context)
        
        let prompt = PromptBuilder.buildInsightPrompt(userMetrics: userMetricsString)
        let jsonString = try await provider.generateJSON(prompt: prompt)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([DailyInsight].self, from: data)
        } catch {
            throw AIProviderError.apiError("Failed to parse Insights JSON: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private
    
    private func buildRealMetricsString(context: ModelContext) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        // Fetch today's health metrics
        var metricDict = [HealthMetricType: Double]()
        do {
            let descriptor = FetchDescriptor<CachedHealthMetric>(
                predicate: #Predicate { $0.id.contains(todayString) }
            )
            let metrics = try context.fetch(descriptor)
            for m in metrics {
                metricDict[m.type] = m.value
            }
        } catch {
            // Continue with whatever we have
        }
        
        // Fetch today's nutrition
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        
        var totalCal = 0.0, totalPro = 0.0, totalCarbs = 0.0, totalFat = 0.0
        do {
            let descriptor = FetchDescriptor<MealLog>(
                predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
            )
            let logs = try context.fetch(descriptor)
            for log in logs {
                let macros = NutritionCalculator.totalMacros(for: log.items)
                totalCal += macros.calories
                totalPro += macros.protein
                totalCarbs += macros.carbs
                totalFat += macros.fat
            }
        } catch {
            // Continue with zeros
        }
        
        // Fetch user targets
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profile = try? context.fetch(profileDescriptor).first
        let calTarget = profile?.dailyCalories ?? 2400
        let proTarget = profile?.targetProteinGram ?? 160
        
        // Fetch today's workouts
        let workoutDescriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.startDate >= startOfDay && $0.isCompleted == true }
        )
        let workoutCount = (try? context.fetch(workoutDescriptor).count) ?? 0
        
        return """
        Calories: \(Int(totalCal))/\(Int(calTarget))
        Protein: \(Int(totalPro))/\(Int(proTarget))g
        Carbs: \(Int(totalCarbs))g
        Fat: \(Int(totalFat))g
        Sleep Score: \(Int(metricDict[.sleepScore] ?? 0))
        Recovery Score: \(Int(metricDict[.recoveryScore] ?? 0))
        Steps: \(Int(metricDict[.steps] ?? 0))
        Resting HR: \(Int(metricDict[.restingHeartRate] ?? 0)) bpm
        HRV: \(Int(metricDict[.hrv] ?? 0)) ms
        Water: \(String(format: "%.1f", metricDict[.waterIntake] ?? 0))L/3L
        Workouts Today: \(workoutCount)
        """
    }
}
