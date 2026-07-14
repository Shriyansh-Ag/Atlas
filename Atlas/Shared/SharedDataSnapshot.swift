import Foundation

// 👱‍♀️ ponytail: single Codable struct is the entire widget data contract.
// Widgets read this JSON from the App Group container. Main app writes it.

/// Lightweight snapshot of app state for widgets and extensions.
/// Kept intentionally flat — no nested SwiftData relationships.
public struct SharedDataSnapshot: Codable {
    // Nutrition
    public var caloriesConsumed: Double
    public var caloriesTarget: Double
    public var proteinConsumed: Double
    public var proteinTarget: Double
    public var carbsConsumed: Double
    public var carbsTarget: Double
    public var fatConsumed: Double
    public var fatTarget: Double
    
    // Health
    public var steps: Int
    public var sleepScore: Int
    public var recoveryScore: Int
    public var waterIntake: Double
    public var waterTarget: Double
    public var bodyWeight: Double
    public var restingHeartRate: Int
    public var vo2Max: Double
    
    // Workout
    public var activeWorkoutName: String?
    public var activeWorkoutStartDate: Date?
    public var nextWorkoutName: String?
    public var todayWorkoutCalories: Double
    public var todayWorkoutMinutes: Int
    
    // Streak & Goals
    public var currentStreak: Int
    public var goalsProgress: [GoalSnapshot]
    
    // Meta
    public var lastUpdated: Date
    
    public init(
        caloriesConsumed: Double = 0,
        caloriesTarget: Double = 2400,
        proteinConsumed: Double = 0,
        proteinTarget: Double = 150,
        carbsConsumed: Double = 0,
        carbsTarget: Double = 300,
        fatConsumed: Double = 0,
        fatTarget: Double = 80,
        steps: Int = 0,
        sleepScore: Int = 0,
        recoveryScore: Int = 0,
        waterIntake: Double = 0,
        waterTarget: Double = 3.0,
        bodyWeight: Double = 0,
        restingHeartRate: Int = 0,
        vo2Max: Double = 0,
        activeWorkoutName: String? = nil,
        activeWorkoutStartDate: Date? = nil,
        nextWorkoutName: String? = nil,
        todayWorkoutCalories: Double = 0,
        todayWorkoutMinutes: Int = 0,
        currentStreak: Int = 0,
        goalsProgress: [GoalSnapshot] = [],
        lastUpdated: Date = Date()
    ) {
        self.caloriesConsumed = caloriesConsumed
        self.caloriesTarget = caloriesTarget
        self.proteinConsumed = proteinConsumed
        self.proteinTarget = proteinTarget
        self.carbsConsumed = carbsConsumed
        self.carbsTarget = carbsTarget
        self.fatConsumed = fatConsumed
        self.fatTarget = fatTarget
        self.steps = steps
        self.sleepScore = sleepScore
        self.recoveryScore = recoveryScore
        self.waterIntake = waterIntake
        self.waterTarget = waterTarget
        self.bodyWeight = bodyWeight
        self.restingHeartRate = restingHeartRate
        self.vo2Max = vo2Max
        self.activeWorkoutName = activeWorkoutName
        self.activeWorkoutStartDate = activeWorkoutStartDate
        self.nextWorkoutName = nextWorkoutName
        self.todayWorkoutCalories = todayWorkoutCalories
        self.todayWorkoutMinutes = todayWorkoutMinutes
        self.currentStreak = currentStreak
        self.goalsProgress = goalsProgress
        self.lastUpdated = lastUpdated
    }
    
    // Computed helpers for widgets
    public var caloriesRemaining: Double { max(0, caloriesTarget - caloriesConsumed) }
    public var proteinRemaining: Double { max(0, proteinTarget - proteinConsumed) }
    public var calorieProgress: Double { caloriesTarget > 0 ? min(caloriesConsumed / caloriesTarget, 1.0) : 0 }
    public var proteinProgress: Double { proteinTarget > 0 ? min(proteinConsumed / proteinTarget, 1.0) : 0 }
    public var waterProgress: Double { waterTarget > 0 ? min(waterIntake / waterTarget, 1.0) : 0 }
}

/// Minimal goal representation for widgets.
public struct GoalSnapshot: Codable, Identifiable {
    public var id: String
    public var title: String
    public var progress: Double // 0.0 to 1.0
    public var isCompleted: Bool
    
    public init(id: String, title: String, progress: Double, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.progress = progress
        self.isCompleted = isCompleted
    }
}
