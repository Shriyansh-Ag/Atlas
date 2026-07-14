import Foundation

@MainActor
public class OpenFoodFactsProvider: FoodProvider {
    public let providerName = "Open Food Facts"
    
    public init() {}
    
    public func search(query: String) async throws -> [FoodItem] {
        try await Task.sleep(nanoseconds: 600_000_000)
        if query.lowercased().contains("chicken") {
            return [
                FoodItem(name: "Chicken Breast", brand: "Generic", calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: 100, servingUnit: "g", provider: providerName, isCustom: false)
            ]
        }
        return []
    }
    
    public func fetchByBarcode(_ barcode: String) async throws -> FoodItem? {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard URL(string: urlString) != nil else { return nil }
        
        // Mocking for now since we don't want to actually block on external network during dev without handling exact schemas
        if barcode == "123456789" {
            return FoodItem(name: "Mock Scanned Item", calories: 250, protein: 10, carbs: 30, fat: 5, servingSize: 1, servingUnit: "serving", barcode: barcode, provider: providerName, isCustom: false)
        }
        
        return nil
    }
}
