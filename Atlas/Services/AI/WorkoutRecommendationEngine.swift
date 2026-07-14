import Foundation
import SwiftData

/// Analyzes workout history and provides AI-powered training recommendations.
public class WorkoutRecommendationEngine {
    public static let shared = WorkoutRecommendationEngine()
    
    private init() {}
    
    public func generateRecommendations(context: ModelContext) async throws -> [WorkoutRecommendation] {
        guard AIConfiguration.shared.enableAICoaching else { return [] }
        
        let provider = AIConfiguration.shared.getProvider()
        let historyString = buildWorkoutHistoryString(context: context)
        
        guard !historyString.isEmpty else { return [] }
        
        let prompt = PromptBuilder.buildWorkoutCoachPrompt(history: historyString)
        let jsonString = try await provider.generateJSON(prompt: prompt)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([WorkoutRecommendation].self, from: data)
        } catch {
            throw AIProviderError.apiError("Failed to parse workout recommendations: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private
    
    private func buildWorkoutHistoryString(context: ModelContext) -> String {
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.startDate >= twoWeeksAgo && $0.isCompleted == true },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 20
        
        guard let sessions = try? context.fetch(descriptor), !sessions.isEmpty else {
            return ""
        }
        
        var summary = "Workout History (last 14 days):\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        for session in sessions {
            let dateStr = dateFormatter.string(from: session.startDate)
            let duration = session.endDate.map { Int($0.timeIntervalSince(session.startDate) / 60) } ?? 0
            summary += "\n[\(dateStr)] \(session.name) — \(duration) min\n"
            
            for exercise in session.exercises.sorted(by: { $0.order < $1.order }) {
                guard let exDef = exercise.exercise else { continue }
                let completedSets = exercise.sets.filter { $0.isCompleted }
                if completedSets.isEmpty { continue }
                
                let setDescriptions = completedSets
                    .sorted(by: { $0.order < $1.order })
                    .map { "\($0.weight)kg × \($0.reps)" }
                    .joined(separator: ", ")
                
                summary += "  • \(exDef.name): \(setDescriptions)\n"
            }
        }
        
        return summary
    }
}
