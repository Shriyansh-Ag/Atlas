import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
public class DailyNutritionManager: ObservableObject {
    public static let shared = DailyNutritionManager()
    
    @Published public var caloriesConsumed: Double = 0
    @Published public var proteinConsumed: Double = 0
    @Published public var carbsConsumed: Double = 0
    @Published public var fatConsumed: Double = 0
    
    public var caloriesTarget: Double = 2400
    public var proteinTarget: Double = 160
    public var carbsTarget: Double = 250
    public var fatTarget: Double = 70
    
    private init() {}
    
    public func update(with context: ModelContext) {
        let repo = MealRepository(context: context)
        let date = Date()
        
        do {
            let logs = try repo.fetchLogs(for: date)
            var c = 0.0, p = 0.0, cb = 0.0, f = 0.0
            for log in logs {
                let m = NutritionCalculator.totalMacros(for: log.items)
                c += m.calories
                p += m.protein
                cb += m.carbs
                f += m.fat
            }
            
            self.caloriesConsumed = c
            self.proteinConsumed = p
            self.carbsConsumed = cb
            self.fatConsumed = f
            
        } catch {
            print("Failed to fetch logs for DailyNutritionManager: \(error)")
        }
    }
}
