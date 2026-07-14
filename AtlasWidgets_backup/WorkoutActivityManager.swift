import Foundation
import ActivityKit

// 👱‍♀️ ponytail: one manager, three methods. That's the entire Live Activity lifecycle.

/// Manages the workout Live Activity lifecycle.
@MainActor
public final class WorkoutActivityManager {
    public static let shared = WorkoutActivityManager()
    
    private var currentActivity: Activity<WorkoutActivityAttributes>?
    
    private init() {}
    
    /// Start a Live Activity for a workout session.
    public func startActivity(workoutName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are disabled")
            return
        }
        
        let attributes = WorkoutActivityAttributes(workoutName: workoutName)
        let initialState = WorkoutActivityAttributes.ContentState()
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil // ponytail: no push updates, local only
            )
        } catch {
            print("⚠️ Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    /// Update the Live Activity with current workout state.
    public func updateActivity(state: WorkoutActivityAttributes.ContentState) {
        guard let activity = currentActivity else { return }
        
        let content = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(content)
        }
    }
    
    /// End the Live Activity gracefully.
    public func endActivity(finalState: WorkoutActivityAttributes.ContentState? = nil) {
        guard let activity = currentActivity else { return }
        
        let state = finalState ?? WorkoutActivityAttributes.ContentState()
        let content = ActivityContent(state: state, staleDate: nil)
        
        Task {
            await activity.end(content, dismissalPolicy: .after(.now + 30))
            currentActivity = nil
        }
    }
    
    /// Whether a Live Activity is currently active.
    public var isActive: Bool {
        currentActivity != nil
    }
}
