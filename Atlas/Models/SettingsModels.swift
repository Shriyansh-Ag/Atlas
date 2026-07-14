import Foundation
import SwiftUI

public enum WeightUnit: String, CaseIterable, Identifiable, Codable {
    case kg, lbs
    public var id: Self { self }
}

public enum DistanceUnit: String, CaseIterable, Identifiable, Codable {
    case km, miles
    public var id: Self { self }
}

public enum EnergyUnit: String, CaseIterable, Identifiable, Codable {
    case kcal, kj
    public var id: Self { self }
}

public enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system, light, dark
    public var id: Self { self }
}

/// Represents the global app preferences, serialized into UserDefaults.
public struct AppPreferences: Codable {
    // Units
    public var weightUnit: WeightUnit = .kg
    public var distanceUnit: DistanceUnit = .km
    public var energyUnit: EnergyUnit = .kcal
    
    // Appearance
    public var theme: AppTheme = .system
    public var useAnimations: Bool = true
    public var glassEffectIntensity: Double = 0.8
    public var useLargeText: Bool = false
    
    // Notifications
    public var workoutReminders: Bool = true
    public var mealReminders: Bool = true
    public var waterReminders: Bool = false
    public var sleepReminders: Bool = true
    public var dailyBriefing: Bool = true
    public var quietHoursEnabled: Bool = true
    
    // Privacy & AI
    public var enableAI: Bool = true
    public var shareDataWithDeveloper: Bool = false
    
    // Accessibility
    public var enableHaptics: Bool = true
    public var highContrast: Bool = false
    public var reduceMotion: Bool = false
    
    // Goals
    public var milestoneCelebrations: Bool = true
    public var strictStreakRules: Bool = false
    
    // Nutrition
    public var defaultMeal: String = "Lunch"
    public var searchBarcodeFirst: Bool = true
    public var prioritizeHighProteinRecipes: Bool = false
    
    // Workout
    public var defaultRestTimerSeconds: Int = 90
    public var autoProgression: Bool = false
    public var defaultWarmupSets: Int = 2
    
    public init() {}
}
