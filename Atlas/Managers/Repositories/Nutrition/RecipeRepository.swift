import SwiftData
import Foundation

@MainActor
public class RecipeRepository {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public init() {
        self.context = AtlasDataContainer.shared.container.mainContext
    }
    
    public func fetchAll() throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>()
        return try context.fetch(descriptor)
    }
    
    public func fetch(byId id: String) throws -> Recipe? {
        var descriptor = FetchDescriptor<Recipe>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
    
    public func save(_ recipe: Recipe) throws {
        context.insert(recipe)
        try context.save()
    }
    
    public func delete(_ recipe: Recipe) throws {
        context.delete(recipe)
        try context.save()
    }
}
