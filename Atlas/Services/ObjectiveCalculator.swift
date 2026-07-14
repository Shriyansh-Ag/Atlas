import Foundation
import SwiftData

/// State of an objective's progress
public enum ObjectiveStatus {
    case completed
    case onTrack
    case behind
    case notStarted
}

/// A lean, stateless calculator that computes progress dynamically 
/// to avoid duplicating SwiftData state into "Engines".
@MainActor
public struct ObjectiveCalculator {
    
    public static func calculateProgress(for objective: AtlasObjective, context: ModelContext) -> (currentValue: Double, status: ObjectiveStatus) {
        
        if objective.isCompleted {
            return (objective.targetValue, .completed)
        }
        
        let now = Date()
        if now > objective.targetDate {
            return (0, .behind) // Past due, logic could be expanded
        }
        
        var currentValue: Double = 0
        
        switch objective.type {
        case .weightLoss, .weightGain, .maintainWeight, .targetBodyFat:
            currentValue = fetchLatestHealthMetric(type: (objective.type == .targetBodyFat) ? .bodyFatPercentage : .weight, context: context)
        case .proteinGoal:
            currentValue = fetchTodayProtein(context: context)
        case .waterGoal:
            currentValue = fetchTodayHealthMetric(type: .waterIntake, context: context)
        case .stepGoal:
            currentValue = fetchTodayHealthMetric(type: .steps, context: context)
        case .sleepGoal:
            currentValue = fetchTodayHealthMetric(type: .sleepScore, context: context) // Or hours if tracked
        case .workoutConsistency:
            currentValue = fetchWorkoutCountThisWeek(context: context)
        case .custom:
            currentValue = 0 // Custom goals require manual updates or specific hooks
        }
        
        let status = determineStatus(current: currentValue, target: objective.targetValue, type: objective.type, start: objective.startDate, end: objective.targetDate)
        
        return (currentValue, status)
    }
    
    // MARK: - Private Data Fetchers
    
    private static func fetchLatestHealthMetric(type: HealthMetricType, context: ModelContext) -> Double {
        var descriptor = FetchDescriptor<CachedHealthMetric>(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first?.value ?? 0.0
    }
    
    private static func fetchTodayHealthMetric(type: HealthMetricType, context: ModelContext) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let id = "\(type.rawValue)_\(dateString)"
        
        var descriptor = FetchDescriptor<CachedHealthMetric>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        
        return (try? context.fetch(descriptor))?.first?.value ?? 0.0
    }
    
    private static func fetchTodayProtein(context: ModelContext) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }
        
        let descriptor = FetchDescriptor<MealLog>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        
        guard let logs = try? context.fetch(descriptor) else { return 0 }
        
        var protein = 0.0
        for log in logs {
            for item in log.items {
                if let food = item.foodItem {
                    protein += food.protein * item.servingQuantity
                }
            }
        }
        return protein
    }
    
    private static func fetchWorkoutCountThisWeek(context: ModelContext) -> Double {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return 0 }
        
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil && $0.startDate >= startOfWeek }
        )
        
        return Double((try? context.fetch(descriptor).count) ?? 0)
    }
    
    // MARK: - Status Logic
    
    private static func determineStatus(current: Double, target: Double, type: ObjectiveType, start: Date, end: Date) -> ObjectiveStatus {
        if current == 0 { return .notStarted }
        
        // Simplified pacing logic
        let totalDuration = end.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)
        let timeProgress = elapsed / totalDuration
        
        // For weight loss, target < start
        if type == .weightLoss || type == .targetBodyFat {
            if current <= target { return .completed }
            // Needs a starting baseline to compute true pace, but for now:
            return .onTrack
        } else {
            if current >= target { return .completed }
            
            let valueProgress = current / target
            if valueProgress >= timeProgress {
                return .onTrack
            } else {
                return .behind
            }
        }
    }
}
