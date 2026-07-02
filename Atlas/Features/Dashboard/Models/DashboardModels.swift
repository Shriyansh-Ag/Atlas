import Foundation

public struct MacroData: Equatable {
    public var proteinConsumed: Double
    public var proteinTarget: Double
    public var carbsConsumed: Double
    public var carbsTarget: Double
    public var fatConsumed: Double
    public var fatTarget: Double
    
    public init(proteinConsumed: Double = 0, proteinTarget: Double = 0, carbsConsumed: Double = 0, carbsTarget: Double = 0, fatConsumed: Double = 0, fatTarget: Double = 0) {
        self.proteinConsumed = proteinConsumed
        self.proteinTarget = proteinTarget
        self.carbsConsumed = carbsConsumed
        self.carbsTarget = carbsTarget
        self.fatConsumed = fatConsumed
        self.fatTarget = fatTarget
    }
}

public struct HealthSnapshot: Equatable {
    public var sleepScore: Int
    public var steps: Int
    public var heartRate: Int
    public var vo2Max: Double
    public var restingHeartRate: Int
    public var waterIntakeLiters: Double
    public var waterTargetLiters: Double
    public var bodyWeightKg: Double
    public var bodyFatPercentage: Double?
    
    public init(sleepScore: Int = 0, steps: Int = 0, heartRate: Int = 0, vo2Max: Double = 0, restingHeartRate: Int = 0, waterIntakeLiters: Double = 0, waterTargetLiters: Double = 0, bodyWeightKg: Double = 0, bodyFatPercentage: Double? = nil) {
        self.sleepScore = sleepScore
        self.steps = steps
        self.heartRate = heartRate
        self.vo2Max = vo2Max
        self.restingHeartRate = restingHeartRate
        self.waterIntakeLiters = waterIntakeLiters
        self.waterTargetLiters = waterTargetLiters
        self.bodyWeightKg = bodyWeightKg
        self.bodyFatPercentage = bodyFatPercentage
    }
}

public struct WorkoutSummary: Equatable {
    public let id: UUID
    public let name: String
    public let durationMinutes: Int
    public let muscleGroups: [String]
    public let exerciseCount: Int
    public let isCompleted: Bool
    
    public init(id: UUID = UUID(), name: String, durationMinutes: Int, muscleGroups: [String], exerciseCount: Int, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.durationMinutes = durationMinutes
        self.muscleGroups = muscleGroups
        self.exerciseCount = exerciseCount
        self.isCompleted = isCompleted
    }
}

public struct StreakData: Equatable {
    public var currentStreak: Int
    public var longestStreak: Int
    public var completedDaysThisWeek: Set<Int> // 1 = Sunday, 7 = Saturday
    
    public init(currentStreak: Int = 0, longestStreak: Int = 0, completedDaysThisWeek: Set<Int> = []) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.completedDaysThisWeek = completedDaysThisWeek
    }
}
