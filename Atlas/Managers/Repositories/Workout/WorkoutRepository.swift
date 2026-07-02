import SwiftData
import Foundation

@MainActor
public class WorkoutRepository {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public init() {
        self.context = AtlasDataContainer.shared.container.mainContext
    }
    
    // MARK: - Plans
    public func fetchPlans() throws -> [WorkoutPlan] {
        let descriptor = FetchDescriptor<WorkoutPlan>()
        return try context.fetch(descriptor)
    }
    
    public func savePlan(_ plan: WorkoutPlan) throws {
        context.insert(plan)
        try context.save()
    }
    
    public func deletePlan(_ plan: WorkoutPlan) throws {
        context.delete(plan)
        try context.save()
    }
    
    // MARK: - Sessions
    public func fetchSessions() throws -> [WorkoutSession] {
        let descriptor = FetchDescriptor<WorkoutSession>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    public func saveSession(_ session: WorkoutSession) throws {
        context.insert(session)
        try context.save()
    }
    
    public func deleteSession(_ session: WorkoutSession) throws {
        context.delete(session)
        try context.save()
    }
}
