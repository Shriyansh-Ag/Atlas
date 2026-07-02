import Foundation

@MainActor
public class USDAProvider: FoodProvider {
    public let providerName = "USDA FoodData Central"
    
    public init() {}
    
    public func search(query: String) async throws -> [FoodItem] {
        // TODO: Implement actual USDA API call when API key is available
        // Mocking some responses
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network
        if query.lowercased().contains("apple") {
            return [
                FoodItem(name: "Apple, raw", brand: nil, calories: 52, protein: 0.3, carbs: 13.8, fat: 0.2, fiber: 2.4, sugar: 10.4, servingSize: 100, servingUnit: "g", provider: providerName, isCustom: false)
            ]
        }
        return []
    }
    
    public func fetchByBarcode(_ barcode: String) async throws -> FoodItem? {
        // USDA supports barcode lookup via FDC branded food endpoint
        return nil
    }
}
