import Foundation

public struct NutritionCalculator {
    public static func totalMacros(for items: [MealItem]) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        var c = 0.0, p = 0.0, cb = 0.0, f = 0.0
        for item in items {
            guard let food = item.foodItem else { continue }
            let q = item.servingQuantity
            c += food.calories * q
            p += food.protein * q
            cb += food.carbs * q
            f += food.fat * q
        }
        return (c, p, cb, f)
    }
    
    public static func totalMacros(for recipe: Recipe) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        var c = 0.0, p = 0.0, cb = 0.0, f = 0.0
        for item in recipe.ingredients {
            guard let food = item.foodItem else { continue }
            let q = item.servingQuantity
            c += food.calories * q
            p += food.protein * q
            cb += food.carbs * q
            f += food.fat * q
        }
        
        let sc = Double(recipe.servingCount > 0 ? recipe.servingCount : 1)
        return (c / sc, p / sc, cb / sc, f / sc) // Per serving
    }
}
