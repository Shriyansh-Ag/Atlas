import Foundation
import SwiftData

public enum ExerciseCategory: String, Codable, CaseIterable {
    case strength = "Strength"
    case bodybuilding = "Bodybuilding"
    case powerlifting = "Powerlifting"
    case olympic = "Olympic Lifting"
    case cardio = "Cardio"
    case mobility = "Mobility"
    case stretching = "Stretching"
    case core = "Core"
}

public enum ExerciseEquipment: String, Codable, CaseIterable {
    case bodyweight = "Bodyweight"
    case machine = "Machine"
    case dumbbell = "Dumbbell"
    case barbell = "Barbell"
    case cable = "Cable"
    case kettlebell = "Kettlebell"
    case resistanceBand = "Resistance Band"
    case none = "None"
}

public enum SetType: String, Codable, CaseIterable {
    case normal = "Normal"
    case warmup = "Warmup"
    case drop = "Drop Set"
    case failure = "Failure"
}

@Model
public class ExerciseDefinition {
    @Attribute(.unique) public var id: String
    public var name: String
    public var primaryMuscle: String
    public var secondaryMuscles: [String]
    public var equipmentRawValue: String
    public var categoryRawValue: String
    public var instructions: String?
    public var isCustom: Bool
    
    public var equipment: ExerciseEquipment {
        get { ExerciseEquipment(rawValue: equipmentRawValue) ?? .none }
        set { equipmentRawValue = newValue.rawValue }
    }
    
    public var category: ExerciseCategory {
        get { ExerciseCategory(rawValue: categoryRawValue) ?? .strength }
        set { categoryRawValue = newValue.rawValue }
    }
    
    public init(id: String = UUID().uuidString, name: String, primaryMuscle: String, secondaryMuscles: [String] = [], equipment: ExerciseEquipment, category: ExerciseCategory, instructions: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscles = secondaryMuscles
        self.equipmentRawValue = equipment.rawValue
        self.categoryRawValue = category.rawValue
        self.instructions = instructions
        self.isCustom = isCustom
    }
}

@Model
public class WorkoutPlan {
    @Attribute(.unique) public var id: String
    public var name: String
    public var planDescription: String?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutPlanDay.plan)
    public var days: [WorkoutPlanDay] = []
    
    public init(id: String = UUID().uuidString, name: String, planDescription: String? = nil) {
        self.id = id
        self.name = name
        self.planDescription = planDescription
    }
}

@Model
public class WorkoutPlanDay {
    @Attribute(.unique) public var id: String
    public var name: String
    public var order: Int
    
    public var plan: WorkoutPlan?
    
    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.day)
    public var exercises: [PlannedExercise] = []
    
    public init(id: String = UUID().uuidString, name: String, order: Int) {
        self.id = id
        self.name = name
        self.order = order
    }
}

@Model
public class PlannedExercise {
    @Attribute(.unique) public var id: String
    public var exercise: ExerciseDefinition?
    public var order: Int
    public var restSeconds: Int
    public var notes: String?
    
    public var day: WorkoutPlanDay?
    
    @Relationship(deleteRule: .cascade, inverse: \PlannedSet.plannedExercise)
    public var sets: [PlannedSet] = []
    
    public init(id: String = UUID().uuidString, exercise: ExerciseDefinition, order: Int, restSeconds: Int = 90, notes: String? = nil) {
        self.id = id
        self.exercise = exercise
        self.order = order
        self.restSeconds = restSeconds
        self.notes = notes
    }
}

@Model
public class PlannedSet {
    @Attribute(.unique) public var id: String
    public var order: Int
    public var targetReps: Int
    public var targetWeight: Double?
    public var targetRPE: Int?
    public var setTypeRawValue: String
    
    public var plannedExercise: PlannedExercise?
    
    public var setType: SetType {
        get { SetType(rawValue: setTypeRawValue) ?? .normal }
        set { setTypeRawValue = newValue.rawValue }
    }
    
    public init(id: String = UUID().uuidString, order: Int, targetReps: Int, targetWeight: Double? = nil, targetRPE: Int? = nil, setType: SetType = .normal) {
        self.id = id
        self.order = order
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.targetRPE = targetRPE
        self.setTypeRawValue = setType.rawValue
    }
}

@Model
public class WorkoutSession {
    @Attribute(.unique) public var id: String
    public var startDate: Date
    public var endDate: Date?
    public var name: String
    public var notes: String?
    public var isCompleted: Bool
    public var totalCalories: Double?
    
    @Relationship(deleteRule: .cascade, inverse: \LoggedExercise.session)
    public var exercises: [LoggedExercise] = []
    
    public init(id: String = UUID().uuidString, startDate: Date = Date(), name: String, isCompleted: Bool = false) {
        self.id = id
        self.startDate = startDate
        self.name = name
        self.isCompleted = isCompleted
    }
}

@Model
public class LoggedExercise {
    @Attribute(.unique) public var id: String
    public var exercise: ExerciseDefinition?
    public var order: Int
    public var notes: String?
    
    public var session: WorkoutSession?
    
    @Relationship(deleteRule: .cascade, inverse: \LoggedSet.loggedExercise)
    public var sets: [LoggedSet] = []
    
    public init(id: String = UUID().uuidString, exercise: ExerciseDefinition, order: Int) {
        self.id = id
        self.exercise = exercise
        self.order = order
    }
}

@Model
public class LoggedSet {
    @Attribute(.unique) public var id: String
    public var order: Int
    public var reps: Int
    public var weight: Double
    public var rpe: Int?
    public var setTypeRawValue: String
    public var isCompleted: Bool
    
    public var loggedExercise: LoggedExercise?
    
    public var setType: SetType {
        get { SetType(rawValue: setTypeRawValue) ?? .normal }
        set { setTypeRawValue = newValue.rawValue }
    }
    
    public init(id: String = UUID().uuidString, order: Int, reps: Int, weight: Double, rpe: Int? = nil, setType: SetType = .normal, isCompleted: Bool = false) {
        self.id = id
        self.order = order
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.setTypeRawValue = setType.rawValue
        self.isCompleted = isCompleted
    }
}
