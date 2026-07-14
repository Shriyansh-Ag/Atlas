import Foundation
import BackgroundTasks
import SwiftData

/// Manages BGAppRefreshTasks to conditionally cancel notifications if goals are already met
@MainActor
public class AtlasBackgroundTaskManager {
    public static let shared = AtlasBackgroundTaskManager()
    
    public let refreshTaskIdentifier = "com.atlas.refresh"
    
    private init() {}
    
    public func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskIdentifier, using: nil) { task in
            guard let appRefreshTask = task as? BGAppRefreshTask else { return }
            self.handleAppRefresh(task: appRefreshTask)
        }
    }
    
    public func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        // Schedule for ~2 hours from now to ensure we check goals periodically in the afternoon
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleNextRefresh() // Reschedule first
        
        task.expirationHandler = {
            // Cancel operations if we run out of time
        }
        
        Task {
            await performBackgroundChecks()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func performBackgroundChecks() async {
        // Run checks on objectives to cancel smart notifications
        // E.g., if workout completed, cancel workout reminder
        let context = AtlasDataContainer.shared.container.mainContext
        
        // Check workouts
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let workoutDescriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil && $0.startDate >= startOfDay }
        )
        let workoutsToday = (try? context.fetch(workoutDescriptor).count) ?? 0
        if workoutsToday > 0 {
            NotificationManager.shared.cancelNotification(id: "workout_reminder")
        }
        
        // We could also dynamically check AtlasObjective for `.proteinGoal` and cancel `protein_reminder`
        // ObjectiveCalculator.calculateProgress(for: proteinObjective, context: context)
    }
}
