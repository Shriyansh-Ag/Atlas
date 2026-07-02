import SwiftData
import Foundation

@MainActor
public class FoodRepository {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public init() {
        self.context = AtlasDataContainer.shared.container.mainContext
    }
    
    public func fetchAll() throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>()
        return try context.fetch(descriptor)
    }
    
    public func fetch(byId id: String) throws -> FoodItem? {
        var descriptor = FetchDescriptor<FoodItem>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
    
    public func fetch(byBarcode barcode: String) throws -> FoodItem? {
        var descriptor = FetchDescriptor<FoodItem>(predicate: #Predicate { $0.barcode == barcode })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
    
    public func fetchCustomFoods() throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(predicate: #Predicate { $0.isCustom == true })
        return try context.fetch(descriptor)
    }
    
    public func save(_ food: FoodItem) throws {
        context.insert(food)
        try context.save()
    }
    
    public func delete(_ food: FoodItem) throws {
        context.delete(food)
        try context.save()
    }
}
