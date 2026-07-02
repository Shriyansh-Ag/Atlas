import SwiftData
import Foundation

@MainActor
public class MealRepository {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public init() {
        self.context = AtlasDataContainer.shared.container.mainContext
    }
    
    public func fetchLog(for date: Date, type: MealType) throws -> MealLog? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let typeString = type.rawValue
        
        var descriptor = FetchDescriptor<MealLog>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay && $0.typeRawValue == typeString }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
    
    public func fetchLogs(for date: Date) throws -> [MealLog] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<MealLog>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        return try context.fetch(descriptor)
    }
    
    public func save(_ log: MealLog) throws {
        context.insert(log)
        try context.save()
    }
    
    public func delete(_ log: MealLog) throws {
        context.delete(log)
        try context.save()
    }
}
