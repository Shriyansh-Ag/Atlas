import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
public class OnboardingViewModel: ObservableObject {
    // Current Step
    @Published public var currentStepIndex: Int = 0
    public let totalSteps: Int = 17
    
    // State for all onboarding fields
    @Published public var name: String = ""
    @Published public var age: Int = 25
    @Published public var biologicalSex: BiologicalSex? = nil
    
    // Physical Metrics
    @Published public var isMetric: Bool = true
    @Published public var heightCm: Double = 170.0
    @Published public var heightFt: Int = 5
    @Published public var heightIn: Int = 7
    @Published public var weightKg: Double = 70.0
    @Published public var weightLbs: Double = 154.0
    @Published public var goalWeightKg: Double? = nil
    @Published public var goalWeightLbs: Double? = nil
    
    // Goals & Activity
    @Published public var fitnessGoal: FitnessGoal? = nil
    @Published public var activityLevel: ActivityLevel? = nil
    @Published public var workoutExperience: WorkoutExperience? = nil
    @Published public var workoutDaysPerWeek: Int = 3
    
    // Diet & Preferences
    @Published public var dietaryPreferences: Set<DietaryPreference> = []
    @Published public var allergies: Set<Allergy> = []
    
    // Settings & Permissions
    @Published public var notificationPermissionGranted: Bool = false
    @Published public var healthKitPermissionRequested: Bool = false
    
    // Dependencies
    private var modelContext: ModelContext?
    
    public init() {}
    
    public func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    public var progress: Double {
        return Double(currentStepIndex + 1) / Double(totalSteps)
    }
    
    public func nextStep() {
        if currentStepIndex < totalSteps - 1 {
            withAnimation(.spring) {
                currentStepIndex += 1
            }
        }
    }
    
    public func previousStep() {
        if currentStepIndex > 0 {
            withAnimation(.spring) {
                currentStepIndex -= 1
            }
        }
    }
    
    public var isCurrentStepValid: Bool {
        switch currentStepIndex {
        case 0: return true // Welcome
        case 1: return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty // Name
        case 2: return age >= 13 && age <= 100 // Age
        case 3: return biologicalSex != nil // Sex
        case 4: return isMetric ? heightCm > 0 : (heightFt > 0) // Height
        case 5: return isMetric ? weightKg > 0 : weightLbs > 0 // Weight
        case 6: return true // Goal Weight (Optional)
        case 7: return fitnessGoal != nil // Fitness Goal
        case 8: return activityLevel != nil // Activity Level
        case 9: return workoutExperience != nil // Workout Experience
        case 10: return workoutDaysPerWeek >= 0 && workoutDaysPerWeek <= 7 // Workout Days
        case 11: return true // Dietary Preference (Optional/None is a choice)
        case 12: return true // Allergies (Optional/Multiple)
        case 13: return true // Notifications
        case 14: return true // HealthKit
        case 15: return true // Summary
        case 16: return true // Finish
        default: return true
        }
    }
    
    // MARK: - Conversions
    
    public var finalHeightCm: Double {
        if isMetric {
            return heightCm
        } else {
            let totalInches = Double(heightFt * 12 + heightIn)
            return totalInches * 2.54
        }
    }
    
    public var finalWeightKg: Double {
        if isMetric {
            return weightKg
        } else {
            return weightLbs * 0.453592
        }
    }
    
    public var finalGoalWeightKg: Double? {
        if let gwKg = goalWeightKg, isMetric {
            return gwKg
        } else if let gwLbs = goalWeightLbs, !isMetric {
            return gwLbs * 0.453592
        }
        return nil
    }
    
    // MARK: - Save
    
    public func saveProfile(completion: @escaping () -> Void) {
        guard let context = modelContext else {
            print("Error: ModelContext is not set.")
            completion()
            return
        }
        
        let bmr = ProfileCalculationService.calculateBMR(weightKg: finalWeightKg, heightCm: finalHeightCm, age: age, sex: biologicalSex ?? .preferNotToSay)
        let tdee = ProfileCalculationService.calculateTDEE(bmr: bmr, activityLevel: activityLevel ?? .moderatelyActive)
        let calories = ProfileCalculationService.calculateDailyCalories(tdee: tdee, goal: fitnessGoal ?? .generalFitness)
        let macros = ProfileCalculationService.calculateMacros(calories: calories, weightKg: finalWeightKg, goal: fitnessGoal ?? .generalFitness)
        
        let newProfile = UserProfile(
            name: name,
            age: age,
            biologicalSex: biologicalSex ?? .preferNotToSay,
            heightCm: finalHeightCm,
            weightKg: finalWeightKg,
            goalWeightKg: finalGoalWeightKg,
            fitnessGoal: fitnessGoal ?? .generalFitness,
            activityLevel: activityLevel ?? .moderatelyActive,
            workoutExperience: workoutExperience ?? .beginner,
            workoutDaysPerWeek: workoutDaysPerWeek,
            dietaryPreferences: Array(dietaryPreferences),
            allergies: Array(allergies),
            preferredUnit: isMetric ? .metric : .imperial,
            notificationPermissionGranted: notificationPermissionGranted,
            healthKitPermissionRequested: healthKitPermissionRequested,
            bmr: bmr,
            tdee: tdee,
            dailyCalories: calories,
            targetProteinGram: macros.protein,
            targetCarbsGram: macros.carbs,
            targetFatGram: macros.fat
        )
        
        context.insert(newProfile)
        
        do {
            try context.save()
            // Mark onboarding as complete using AppStorage/UserDefaults
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            completion()
        } catch {
            print("Failed to save profile: \(error)")
            completion()
        }
    }
}
