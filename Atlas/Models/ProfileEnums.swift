import Foundation

public enum BiologicalSex: String, Codable, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case preferNotToSay = "Prefer not to say"
    
    public var id: String { self.rawValue }
}

public enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case loseFat = "Lose Fat"
    case buildMuscle = "Build Muscle"
    case maintain = "Maintain"
    case bodyRecomposition = "Body Recomposition"
    case improveEndurance = "Improve Endurance"
    case generalFitness = "General Fitness"
    
    public var id: String { self.rawValue }
}

public enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case athlete = "Athlete"
    
    public var id: String { self.rawValue }
    
    public var description: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .lightlyActive: return "Light exercise 1-3 days/week"
        case .moderatelyActive: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Heavy exercise 6-7 days/week"
        case .athlete: return "Very heavy exercise, physical job, or training twice a day"
        }
    }
}

public enum WorkoutExperience: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    public var id: String { self.rawValue }
}

public enum DietaryPreference: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case pescatarian = "Pescatarian"
    case keto = "Keto"
    case highProtein = "High Protein"
    case lowCarb = "Low Carb"
    case glutenFree = "Gluten Free"
    
    public var id: String { self.rawValue }
}

public enum Allergy: String, Codable, CaseIterable, Identifiable {
    case peanuts = "Peanuts"
    case treeNuts = "Tree Nuts"
    case milk = "Milk"
    case egg = "Egg"
    case soy = "Soy"
    case fish = "Fish"
    case shellfish = "Shellfish"
    case wheat = "Wheat"
    case sesame = "Sesame"
    case other = "Other"
    
    public var id: String { self.rawValue }
}

public enum UnitPreference: String, Codable, CaseIterable, Identifiable {
    case metric = "Metric (kg, cm)"
    case imperial = "Imperial (lbs, ft/in)"
    
    public var id: String { self.rawValue }
}
