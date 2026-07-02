import Foundation

public protocol WorkoutServiceProtocol {
    func fetchTodaysWorkout() async throws -> WorkoutSummary?
    func fetchWeeklyStreak() async throws -> StreakData
}

public class WorkoutService: WorkoutServiceProtocol {
    public init() {}
    
    public func fetchTodaysWorkout() async throws -> WorkoutSummary? {
        return nil
    }
    
    public func fetchWeeklyStreak() async throws -> StreakData {
        return StreakData(currentStreak: 0, longestStreak: 0, completedDaysThisWeek: [])
    }
}
