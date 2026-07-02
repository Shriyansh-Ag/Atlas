import Foundation
import SwiftData

@Model
public class FoodItem {
    @Attribute(.unique) public var id: String
    public var name: String
    public var brand: String?
    
    // Nutrition Facts (Per default serving size)
    public var calories: Double
    public var protein: Double
    public var carbs: Double
    public var fat: Double
    public var fiber: Double?
    public var sugar: Double?
    public var sodium: Double?
    
    // Serving Info
    public var servingSize: Double
    public var servingUnit: String
    
    // Identifiers & Meta
    public var barcode: String?
    public var provider: String // e.g. "USDA", "OpenFoodFacts", "Custom"
    public var isCustom: Bool
    
    public init(id: String = UUID().uuidString, name: String, brand: String? = nil, calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double? = nil, sugar: Double? = nil, sodium: Double? = nil, servingSize: Double, servingUnit: String, barcode: String? = nil, provider: String = "Custom", isCustom: Bool = true) {
        self.id = id
        self.name = name
        self.brand = brand
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.barcode = barcode
        self.provider = provider
        self.isCustom = isCustom
    }
}

public enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case snack
}

@Model
public class MealItem {
    @Attribute(.unique) public var id: String
    public var foodItem: FoodItem?
    public var servingQuantity: Double // A multiplier of the foodItem's base servingSize
    
    @Relationship(inverse: \MealLog.items) public var log: MealLog?
    
    public init(id: String = UUID().uuidString, foodItem: FoodItem, servingQuantity: Double) {
        self.id = id
        self.foodItem = foodItem
        self.servingQuantity = servingQuantity
    }
}

@Model
public class MealLog {
    @Attribute(.unique) public var id: String
    public var date: Date
    public var typeRawValue: String
    
    public var type: MealType {
        get { MealType(rawValue: typeRawValue) ?? .snack }
        set { typeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .cascade) public var items: [MealItem] = []
    
    public init(id: String = UUID().uuidString, date: Date, type: MealType) {
        self.id = id
        self.date = date
        self.typeRawValue = type.rawValue
    }
}

@Model
public class Recipe {
    @Attribute(.unique) public var id: String
    public var name: String
    public var instructions: String?
    public var imagePath: String?
    public var servingCount: Int
    
    @Relationship(deleteRule: .cascade) public var ingredients: [RecipeIngredient] = []
    
    public init(id: String = UUID().uuidString, name: String, instructions: String? = nil, imagePath: String? = nil, servingCount: Int = 1) {
        self.id = id
        self.name = name
        self.instructions = instructions
        self.imagePath = imagePath
        self.servingCount = servingCount
    }
}

@Model
public class RecipeIngredient {
    @Attribute(.unique) public var id: String
    public var foodItem: FoodItem?
    public var servingQuantity: Double
    
    @Relationship(inverse: \Recipe.ingredients) public var recipe: Recipe?
    
    public init(id: String = UUID().uuidString, foodItem: FoodItem, servingQuantity: Double) {
        self.id = id
        self.foodItem = foodItem
        self.servingQuantity = servingQuantity
    }
}
