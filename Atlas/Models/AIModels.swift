import Foundation
import SwiftData

// MARK: - Meal Recognition

public struct AIFoodItem: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var calories: Double
    public var protein: Double
    public var carbs: Double
    public var fat: Double
    public var fiber: Double?
    public var sugar: Double?
    public var confidence: Double
    
    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fat, fiber, sugar, confidence
    }
}

// MARK: - Daily Insights

public struct DailyInsight: Codable, Identifiable {
    public var id = UUID()
    public var title: String
    public var message: String
    public var category: InsightCategory
    
    public enum InsightCategory: String, Codable {
        case nutrition = "Nutrition"
        case workout = "Workout"
        case recovery = "Recovery"
        case general = "General"
    }
    
    enum CodingKeys: String, CodingKey {
        case title, message, category
    }
}

// MARK: - Weekly Report

public struct WeeklyReport: Codable {
    public var summaryText: String
    public var bestWorkout: String?
    public var suggestedFocus: String
    public var adherenceScore: Double
}

public struct WeeklyReportData: Codable {
    public var workoutConsistency: Double // Percentage 0-100
    public var nutritionConsistency: Double
    public var averageSleepScore: Double
    public var weightTrend: String // e.g. "Down 0.5kg", "Stable", "Up 0.3kg"
    public var macroAdherence: Double // Percentage 0-100
    public var bestWorkout: String
    public var suggestedFocus: String
    public var summaryText: String
    public var highlights: [String]
    
    public init(
        workoutConsistency: Double = 0,
        nutritionConsistency: Double = 0,
        averageSleepScore: Double = 0,
        weightTrend: String = "Stable",
        macroAdherence: Double = 0,
        bestWorkout: String = "None",
        suggestedFocus: String = "",
        summaryText: String = "",
        highlights: [String] = []
    ) {
        self.workoutConsistency = workoutConsistency
        self.nutritionConsistency = nutritionConsistency
        self.averageSleepScore = averageSleepScore
        self.weightTrend = weightTrend
        self.macroAdherence = macroAdherence
        self.bestWorkout = bestWorkout
        self.suggestedFocus = suggestedFocus
        self.summaryText = summaryText
        self.highlights = highlights
    }
}

// MARK: - Workout Recommendations

public struct WorkoutRecommendation: Codable, Identifiable {
    public var id = UUID()
    public var suggestionType: SuggestionType
    public var exerciseName: String?
    public var message: String
    public var reasoning: String
    public var confidence: Double
    
    public enum SuggestionType: String, Codable {
        case increaseWeight = "increase_weight"
        case increaseReps = "increase_reps"
        case deload = "deload"
        case reduceFatigue = "reduce_fatigue"
        case swapExercise = "swap_exercise"
        case restDay = "rest_day"
        case addExercise = "add_exercise"
    }
    
    enum CodingKeys: String, CodingKey {
        case suggestionType = "suggestion_type"
        case exerciseName = "exercise_name"
        case message, reasoning, confidence
    }
}

// MARK: - Nutrition Recommendations

public struct NutritionRecommendation: Codable, Identifiable {
    public var id = UUID()
    public var suggestionType: SuggestionType
    public var message: String
    public var details: String?
    
    public enum SuggestionType: String, Codable {
        case mealSuggestion = "meal_suggestion"
        case proteinIntake = "protein_intake"
        case hydration = "hydration"
        case healthySubstitution = "substitution"
        case mealTiming = "meal_timing"
        case calorieAdjustment = "calorie_adjustment"
    }
    
    enum CodingKeys: String, CodingKey {
        case suggestionType = "suggestion_type"
        case message, details
    }
}

// MARK: - Recovery Recommendations

public struct RecoveryRecommendation: Codable, Identifiable {
    public var id = UUID()
    public var recommendationType: RecommendationType
    public var message: String
    public var reasoning: String
    
    public enum RecommendationType: String, Codable {
        case rest = "rest"
        case lightWorkout = "light_workout"
        case heavyWorkout = "heavy_workout"
        case mobility = "mobility"
        case sleep = "sleep"
    }
    
    enum CodingKeys: String, CodingKey {
        case recommendationType = "recommendation_type"
        case message, reasoning
    }
}

// MARK: - Recipe Suggestions

public struct RecipeSuggestion: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var ingredients: [RecipeIngredientItem]
    public var instructions: [String]
    public var estimatedCalories: Double
    public var estimatedProtein: Double
    public var estimatedCarbs: Double
    public var estimatedFat: Double
    public var servings: Int
    
    public struct RecipeIngredientItem: Codable {
        public var name: String
        public var quantity: String
    }
    
    enum CodingKeys: String, CodingKey {
        case name, ingredients, instructions
        case estimatedCalories = "estimated_calories"
        case estimatedProtein = "estimated_protein"
        case estimatedCarbs = "estimated_carbs"
        case estimatedFat = "estimated_fat"
        case servings
    }
}

// MARK: - Meal Plan

public struct MealPlanDay: Codable, Identifiable {
    public var id = UUID()
    public var dayLabel: String // e.g. "Monday" or "Day 1"
    public var breakfast: MealPlanEntry
    public var lunch: MealPlanEntry
    public var dinner: MealPlanEntry
    public var snack: MealPlanEntry?
    
    public struct MealPlanEntry: Codable {
        public var name: String
        public var description: String
        public var estimatedCalories: Double
        public var estimatedProtein: Double
        public var estimatedCarbs: Double
        public var estimatedFat: Double
        
        enum CodingKeys: String, CodingKey {
            case name, description
            case estimatedCalories = "estimated_calories"
            case estimatedProtein = "estimated_protein"
            case estimatedCarbs = "estimated_carbs"
            case estimatedFat = "estimated_fat"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case dayLabel = "day_label"
        case breakfast, lunch, dinner, snack
    }
}

// MARK: - Food Correction (Local Learning)

@Model
public class AIFoodCorrection {
    @Attribute(.unique) public var id: String
    public var originalName: String
    public var correctedName: String
    public var originalCalories: Double
    public var correctedCalories: Double
    public var correctedProtein: Double
    public var correctedCarbs: Double
    public var correctedFat: Double
    public var date: Date
    
    public init(
        id: String = UUID().uuidString,
        originalName: String,
        correctedName: String,
        originalCalories: Double,
        correctedCalories: Double,
        correctedProtein: Double,
        correctedCarbs: Double,
        correctedFat: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.originalName = originalName
        self.correctedName = correctedName
        self.originalCalories = originalCalories
        self.correctedCalories = correctedCalories
        self.correctedProtein = correctedProtein
        self.correctedCarbs = correctedCarbs
        self.correctedFat = correctedFat
        self.date = date
    }
}
