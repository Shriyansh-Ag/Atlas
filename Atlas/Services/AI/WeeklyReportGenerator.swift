import Foundation
import SwiftData

/// Generates comprehensive weekly fitness reports using AI analysis.
public class WeeklyReportGenerator {
    public static let shared = WeeklyReportGenerator()
    
    private init() {}
    
    public func generateReport(context: ModelContext) async throws -> WeeklyReportData {
        guard AIConfiguration.shared.enableWeeklyReports else {
            throw AIProviderError.featureDisabled
        }
        
        let provider = AIConfiguration.shared.getProvider()
        let weekDataString = buildWeekDataString(context: context)
        
        let prompt = PromptBuilder.buildWeeklyReportPrompt(weekData: weekDataString)
        let jsonString = try await provider.generateJSON(prompt: prompt)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeeklyReportData.self, from: data)
        } catch {
            throw AIProviderError.apiError("Failed to parse weekly report: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private
    
    private func buildWeekDataString(context: ModelContext) -> String {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        // Workout data
        let workoutDescriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.startDate >= sevenDaysAgo && $0.isCompleted == true },
            sortBy: [SortDescriptor(\.startDate)]
        )
        let sessions = (try? context.fetch(workoutDescriptor)) ?? []
        
        var workoutSummary = "Workouts this week: \(sessions.count)\n"
        for session in sessions {
            let dateStr = dateFormatter.string(from: session.startDate)
            let duration = session.endDate.map { Int($0.timeIntervalSince(session.startDate) / 60) } ?? 0
            let exerciseCount = session.exercises.count
            workoutSummary += "  [\(dateStr)] \(session.name) — \(duration) min, \(exerciseCount) exercises\n"
        }
        
        // Nutrition data
        let nutritionDescriptor = FetchDescriptor<MealLog>(
            predicate: #Predicate { $0.date >= sevenDaysAgo },
            sortBy: [SortDescriptor(\.date)]
        )
        let mealLogs = (try? context.fetch(nutritionDescriptor)) ?? []
        
        let grouped = Dictionary(grouping: mealLogs) { log in
            calendar.startOfDay(for: log.date)
        }
        
        var nutritionSummary = "Nutrition this week (\(grouped.count) days logged):\n"
        for (day, dayLogs) in grouped.sorted(by: { $0.key < $1.key }) {
            var totalCal = 0.0, totalPro = 0.0
            for log in dayLogs {
                let macros = NutritionCalculator.totalMacros(for: log.items)
                totalCal += macros.calories
                totalPro += macros.protein
            }
            nutritionSummary += "  [\(dateFormatter.string(from: day))] \(Int(totalCal)) kcal, \(Int(totalPro))g protein\n"
        }
        
        // Health metrics (grab the week's worth)
        let healthDescriptor = FetchDescriptor<CachedHealthMetric>(
            predicate: #Predicate { $0.date >= sevenDaysAgo }
        )
        let healthMetrics = (try? context.fetch(healthDescriptor)) ?? []
        
        let sleepScores = healthMetrics.filter { $0.type == .sleepScore }.map(\.value)
        let avgSleep = sleepScores.isEmpty ? 0 : sleepScores.reduce(0, +) / Double(sleepScores.count)
        
        let weights = healthMetrics.filter { $0.type == .weight }.sorted(by: { $0.date < $1.date })
        var weightTrend = "No weight data"
        if let first = weights.first, let last = weights.last, weights.count >= 2 {
            let diff = last.value - first.value
            weightTrend = diff > 0 ? "Up \(String(format: "%.1f", diff))kg" : diff < 0 ? "Down \(String(format: "%.1f", abs(diff)))kg" : "Stable"
        }
        
        // User targets for adherence calculation
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profile = try? context.fetch(profileDescriptor).first
        let calorieTarget = profile?.dailyCalories ?? 2400
        
        return """
        \(workoutSummary)
        \(nutritionSummary)
        Health Overview:
        - Average Sleep Score: \(Int(avgSleep))/100
        - Weight Trend: \(weightTrend)
        - Daily Calorie Target: \(Int(calorieTarget)) kcal
        
        User Goal: \(profile?.fitnessGoal.rawValue ?? "General Fitness")
        Target Workout Days/Week: \(profile?.workoutDaysPerWeek ?? 4)
        """
    }
}
