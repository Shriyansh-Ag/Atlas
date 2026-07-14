import Foundation
import ActivityKit

/// ActivityAttributes for a live workout session.
/// Used by Live Activities and Dynamic Island.
public struct WorkoutActivityAttributes: ActivityAttributes {
    /// Static context — set once when the activity stxarts.
    public var workoutName: String
    public var startDate: Date
    
    /// Dynamic state — updated throughout the workout.
    public struct ContentState: Codable, Hashable {
        public var elapsedSeconds: Int
        public var currentExercise: String
        public var currentSetInfo: String // e.g. "Set 3 of 4"
        public var remainingRestSeconds: Int // 0 if not resting
        public var estimatedCalories: Int
        public var completedExercises: Int
        public var totalExercises: Int
        
        public var isResting: Bool { remainingRestSeconds > 0 }
        
        public var progress: Double {
            totalExercises > 0 ? Double(completedExercises) / Double(totalExercises) : 0
        }
        
        public var formattedDuration: String {
            let min = elapsedSeconds / 60
            let sec = elapsedSeconds % 60
            return String(format: "%d:%02d", min, sec)
        }
        
        public var formattedRest: String {
            let min = remainingRestSeconds / 60
            let sec = remainingRestSeconds % 60
            return String(format: "%d:%02d", min, sec)
        }
        
        public init(
            elapsedSeconds: Int = 0,
            currentExercise: String = "",
            currentSetInfo: String = "",
            remainingRestSeconds: Int = 0,
            estimatedCalories: Int = 0,
            completedExercises: Int = 0,
            totalExercises: Int = 0
        ) {
            self.elapsedSeconds = elapsedSeconds
            self.currentExercise = currentExercise
            self.currentSetInfo = currentSetInfo
            self.remainingRestSeconds = remainingRestSeconds
            self.estimatedCalories = estimatedCalories
            self.completedExercises = completedExercises
            self.totalExercises = totalExercises
        }
    }
    
    public init(workoutName: String, startDate: Date = Date()) {
        self.workoutName = workoutName
        self.startDate = startDate
    }
}
