import SwiftData
import Foundation

/// SwiftData repository for AI-specific persistence (food corrections, cached insights).
@MainActor
public class AIRepository {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public init() {
        self.context = AtlasDataContainer.shared.container.mainContext
    }
    
    // MARK: - Food Corrections
    
    public func saveCorrection(_ correction: AIFoodCorrection) throws {
        context.insert(correction)
        try context.save()
    }
    
    public func fetchRecentCorrections(limit: Int = 20) throws -> [AIFoodCorrection] {
        var descriptor = FetchDescriptor<AIFoodCorrection>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }
    
    /// Builds a correction context string to append to meal recognition prompts,
    /// so the AI can learn from past user corrections.
    public func buildCorrectionContext() -> String? {
        guard let corrections = try? fetchRecentCorrections(limit: 10), !corrections.isEmpty else {
            return nil
        }
        
        var context = "Previous user corrections (learn from these):\n"
        for c in corrections {
            context += "- \"\(c.originalName)\" was corrected to \"\(c.correctedName)\""
            context += " (\(Int(c.correctedCalories)) kcal, \(Int(c.correctedProtein))g P)\n"
        }
        return context
    }
    
    public func deleteAllCorrections() throws {
        try context.delete(model: AIFoodCorrection.self)
        try context.save()
    }
}
