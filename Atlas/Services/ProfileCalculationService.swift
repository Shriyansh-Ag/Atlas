import Foundation

public struct ProfileCalculationService {
    
    /// Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation.
    ///
    /// - Parameters:
    ///   - weightKg: Weight in kilograms.
    ///   - heightCm: Height in centimeters.
    ///   - age: Age in years.
    ///   - sex: Biological sex.
    /// - Returns: BMR in kcal/day.
    public static func calculateBMR(weightKg: Double, heightCm: Double, age: Int, sex: BiologicalSex) -> Double {
        let weightTerm = 10.0 * weightKg
        let heightTerm = 6.25 * heightCm
        let ageTerm = 5.0 * Double(age)
        
        let baseBMR = weightTerm + heightTerm - ageTerm
        
        switch sex {
        case .male:
            return baseBMR + 5.0
        case .female:
            return baseBMR - 161.0
        case .preferNotToSay:
            // Use average of male and female for generic estimation
            return baseBMR - 78.0
        }
    }
    
    /// Calculates Total Daily Energy Expenditure (TDEE) based on BMR and activity level.
    public static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        let multiplier: Double
        switch activityLevel {
        case .sedentary:
            multiplier = 1.2
        case .lightlyActive:
            multiplier = 1.375
        case .moderatelyActive:
            multiplier = 1.55
        case .veryActive:
            multiplier = 1.725
        case .athlete:
            multiplier = 1.9
        }
        return bmr * multiplier
    }
    
    /// Calculates daily calorie goal based on TDEE and fitness goal.
    public static func calculateDailyCalories(tdee: Double, goal: FitnessGoal) -> Double {
        switch goal {
        case .loseFat:
            return tdee - 500 // ~1lb fat loss per week
        case .buildMuscle:
            return tdee + 300 // Slight surplus
        case .maintain:
            return tdee
        case .bodyRecomposition:
            return tdee - 200 // Slight deficit for recomposition
        case .improveEndurance, .generalFitness:
            return tdee
        }
    }
    
    /// Calculates macro breakdown (Protein, Carbs, Fat) in grams.
    public static func calculateMacros(calories: Double, weightKg: Double, goal: FitnessGoal) -> (protein: Double, carbs: Double, fat: Double) {
        // Base protein recommendation (grams per kg of body weight)
        let proteinPerKg: Double
        switch goal {
        case .buildMuscle, .bodyRecomposition:
            proteinPerKg = 2.2
        case .loseFat:
            proteinPerKg = 2.0 // High protein to preserve muscle during deficit
        case .maintain, .improveEndurance, .generalFitness:
            proteinPerKg = 1.8
        }
        
        let proteinGrams = weightKg * proteinPerKg
        let proteinCalories = proteinGrams * 4.0
        
        // Fat recommendation: 25-30% of total calories based on goal
        let fatPercentage: Double
        switch goal {
        case .loseFat:
            fatPercentage = 0.25
        case .buildMuscle, .maintain, .bodyRecomposition, .generalFitness:
            fatPercentage = 0.30
        case .improveEndurance:
            fatPercentage = 0.25 // More room for carbs
        }
        
        let fatCalories = calories * fatPercentage
        let fatGrams = fatCalories / 9.0
        
        // Remaining calories for carbs
        let remainingCalories = calories - proteinCalories - fatCalories
        let carbsGrams = max(0, remainingCalories / 4.0) // Ensure non-negative
        
        return (protein: proteinGrams, carbs: carbsGrams, fat: fatGrams)
    }
}
