import Foundation
import SwiftData

@Model
public class UserProfile {
    // Basic Info
    public var name: String
    public var age: Int
    public var biologicalSexRaw: String // Store as string for SwiftData simplicity
    
    // Physical Metrics (stored internally in metric)
    public var heightCm: Double
    public var weightKg: Double
    public var goalWeightKg: Double?
    
    // Goals & Activity
    public var fitnessGoalRaw: String
    public var activityLevelRaw: String
    public var workoutExperienceRaw: String
    public var workoutDaysPerWeek: Int
    
    // Diet & Preferences
    public var dietaryPreferencesRaw: [String] // Array of string values
    public var allergiesRaw: [String]
    
    // Settings & Permissions
    public var preferredUnitRaw: String
    public var notificationPermissionGranted: Bool
    public var healthKitPermissionRequested: Bool
    
    // Calculated Values (can be updated later)
    public var bmr: Double
    public var tdee: Double
    public var dailyCalories: Double
    public var targetProteinGram: Double
    public var targetCarbsGram: Double
    public var targetFatGram: Double
    
    // Metadata
    public var createdAt: Date
    public var lastUpdatedAt: Date
    
    // Computed Properties for Enums
    @Transient public var biologicalSex: BiologicalSex {
        get { BiologicalSex(rawValue: biologicalSexRaw) ?? .preferNotToSay }
        set { biologicalSexRaw = newValue.rawValue }
    }
    
    @Transient public var fitnessGoal: FitnessGoal {
        get { FitnessGoal(rawValue: fitnessGoalRaw) ?? .generalFitness }
        set { fitnessGoalRaw = newValue.rawValue }
    }
    
    @Transient public var activityLevel: ActivityLevel {
        get { ActivityLevel(rawValue: activityLevelRaw) ?? .moderatelyActive }
        set { activityLevelRaw = newValue.rawValue }
    }
    
    @Transient public var workoutExperience: WorkoutExperience {
        get { WorkoutExperience(rawValue: workoutExperienceRaw) ?? .beginner }
        set { workoutExperienceRaw = newValue.rawValue }
    }
    
    @Transient public var preferredUnit: UnitPreference {
        get { UnitPreference(rawValue: preferredUnitRaw) ?? .metric }
        set { preferredUnitRaw = newValue.rawValue }
    }
    
    @Transient public var dietaryPreferences: [DietaryPreference] {
        get { dietaryPreferencesRaw.compactMap { DietaryPreference(rawValue: $0) } }
        set { dietaryPreferencesRaw = newValue.map { $0.rawValue } }
    }
    
    @Transient public var allergies: [Allergy] {
        get { allergiesRaw.compactMap { Allergy(rawValue: $0) } }
        set { allergiesRaw = newValue.map { $0.rawValue } }
    }
    
    public init(
        name: String,
        age: Int,
        biologicalSex: BiologicalSex,
        heightCm: Double,
        weightKg: Double,
        goalWeightKg: Double? = nil,
        fitnessGoal: FitnessGoal,
        activityLevel: ActivityLevel,
        workoutExperience: WorkoutExperience,
        workoutDaysPerWeek: Int,
        dietaryPreferences: [DietaryPreference],
        allergies: [Allergy],
        preferredUnit: UnitPreference,
        notificationPermissionGranted: Bool,
        healthKitPermissionRequested: Bool,
        bmr: Double = 0.0,
        tdee: Double = 0.0,
        dailyCalories: Double = 0.0,
        targetProteinGram: Double = 0.0,
        targetCarbsGram: Double = 0.0,
        targetFatGram: Double = 0.0
    ) {
        self.name = name
        self.age = age
        self.biologicalSexRaw = biologicalSex.rawValue
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.goalWeightKg = goalWeightKg
        self.fitnessGoalRaw = fitnessGoal.rawValue
        self.activityLevelRaw = activityLevel.rawValue
        self.workoutExperienceRaw = workoutExperience.rawValue
        self.workoutDaysPerWeek = workoutDaysPerWeek
        self.dietaryPreferencesRaw = dietaryPreferences.map { $0.rawValue }
        self.allergiesRaw = allergies.map { $0.rawValue }
        self.preferredUnitRaw = preferredUnit.rawValue
        self.notificationPermissionGranted = notificationPermissionGranted
        self.healthKitPermissionRequested = healthKitPermissionRequested
        self.bmr = bmr
        self.tdee = tdee
        self.dailyCalories = dailyCalories
        self.targetProteinGram = targetProteinGram
        self.targetCarbsGram = targetCarbsGram
        self.targetFatGram = targetFatGram
        self.createdAt = Date()
        self.lastUpdatedAt = Date()
    }
}
