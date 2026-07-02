import Foundation

public protocol NutritionServiceProtocol {
    func fetchDailyMacros() async throws -> MacroData
    func fetchDailyCaloriesConsumed() async throws -> Double
    func fetchDailyCaloriesTarget() async throws -> Double
    func fetchDailyWaterIntake() async throws -> Double
    func fetchDailyWaterTarget() async throws -> Double
}

public class NutritionService: NutritionServiceProtocol {
    public init() {}
    
    public func fetchDailyMacros() async throws -> MacroData {
        return MacroData(proteinConsumed: 0, proteinTarget: 0, carbsConsumed: 0, carbsTarget: 0, fatConsumed: 0, fatTarget: 0)
    }
    
    public func fetchDailyCaloriesConsumed() async throws -> Double { return 0 }
    public func fetchDailyCaloriesTarget() async throws -> Double { return 0 }
    
    public func fetchDailyWaterIntake() async throws -> Double { return 0 }
    public func fetchDailyWaterTarget() async throws -> Double { return 0 }
}
