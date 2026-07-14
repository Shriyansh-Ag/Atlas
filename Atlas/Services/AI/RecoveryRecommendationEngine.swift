import Foundation
import SwiftData

/// Analyzes recovery metrics and provides AI-powered recovery recommendations.
public class RecoveryRecommendationEngine {
    public static let shared = RecoveryRecommendationEngine()
    
    private init() {}
    
    public func generateRecommendations(context: ModelContext) async throws -> [RecoveryRecommendation] {
        guard AIConfiguration.shared.enableAICoaching else { return [] }
        
        let provider = AIConfiguration.shared.getProvider()
        let healthString = buildHealthString(context: context)
        
        let prompt = PromptBuilder.buildRecoveryCoachPrompt(health: healthString)
        let jsonString = try await provider.generateJSON(prompt: prompt)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([RecoveryRecommendation].self, from: data)
        } catch {
            throw AIProviderError.apiError("Failed to parse recovery recommendations: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private
    
    private func buildHealthString(context: ModelContext) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        // Fetch today's cached health metrics
        let metrics: [CachedHealthMetric]
        do {
            let descriptor = FetchDescriptor<CachedHealthMetric>(
                predicate: #Predicate { $0.id.contains(todayString) }
            )
            metrics = try context.fetch(descriptor)
        } catch {
            metrics = []
        }
        
        var metricDict = [HealthMetricType: Double]()
        for m in metrics {
            metricDict[m.type] = m.value
        }
        
        // Fetch recent workout volume
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let recentSessions: [WorkoutSession]
        do {
            let descriptor = FetchDescriptor<WorkoutSession>(
                predicate: #Predicate { $0.startDate >= threeDaysAgo && $0.isCompleted == true }
            )
            recentSessions = try context.fetch(descriptor)
        } catch {
            recentSessions = []
        }
        
        let totalWorkoutMinutes = recentSessions.reduce(0.0) { total, session in
            guard let end = session.endDate else { return total }
            return total + end.timeIntervalSince(session.startDate) / 60.0
        }
        
        return """
        Today's Recovery Data:
        - Recovery Score: \(Int(metricDict[.recoveryScore] ?? 0))/100
        - Sleep Score: \(Int(metricDict[.sleepScore] ?? 0))/100
        - HRV: \(Int(metricDict[.hrv] ?? 0)) ms
        - Resting Heart Rate: \(Int(metricDict[.restingHeartRate] ?? 0)) bpm
        - Steps Today: \(Int(metricDict[.steps] ?? 0))
        
        Recent Training Load (last 3 days):
        - Workouts completed: \(recentSessions.count)
        - Total training time: \(Int(totalWorkoutMinutes)) minutes
        """
    }
}
