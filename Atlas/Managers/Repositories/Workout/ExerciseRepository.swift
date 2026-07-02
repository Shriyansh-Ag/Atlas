import SwiftData
import Foundation

@MainActor
public class ExerciseRepository {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public init() {
        self.context = AtlasDataContainer.shared.container.mainContext
    }
    
    public func fetchAll() throws -> [ExerciseDefinition] {
        let descriptor = FetchDescriptor<ExerciseDefinition>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    public func search(query: String) throws -> [ExerciseDefinition] {
        if query.isEmpty { return try fetchAll() }
        let all = try fetchAll()
        return all.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.primaryMuscle.localizedCaseInsensitiveContains(query) }
    }
    
    public func save(_ exercise: ExerciseDefinition) throws {
        context.insert(exercise)
        try context.save()
    }
    
    public func delete(_ exercise: ExerciseDefinition) throws {
        context.delete(exercise)
        try context.save()
    }
    
    public func seedInitialExercisesIfNeeded() {
        do {
            let existing = try fetchAll()
            if existing.count < 10 {
                let initial = [
                    ExerciseDefinition(name: "Bench Press", primaryMuscle: "Chest", secondaryMuscles: ["Triceps", "Shoulders"], equipment: .barbell, category: .strength),
                    ExerciseDefinition(name: "Incline Dumbbell Press", primaryMuscle: "Chest", secondaryMuscles: ["Triceps", "Shoulders"], equipment: .dumbbell, category: .strength),
                    ExerciseDefinition(name: "Squat", primaryMuscle: "Quadriceps", secondaryMuscles: ["Glutes", "Hamstrings"], equipment: .barbell, category: .strength),
                    ExerciseDefinition(name: "Leg Press", primaryMuscle: "Quadriceps", secondaryMuscles: ["Glutes"], equipment: .machine, category: .strength),
                    ExerciseDefinition(name: "Deadlift", primaryMuscle: "Hamstrings", secondaryMuscles: ["Glutes", "Lower Back"], equipment: .barbell, category: .strength),
                    ExerciseDefinition(name: "Romanian Deadlift", primaryMuscle: "Hamstrings", secondaryMuscles: ["Glutes", "Lower Back"], equipment: .dumbbell, category: .strength),
                    ExerciseDefinition(name: "Pull Up", primaryMuscle: "Lats", secondaryMuscles: ["Biceps"], equipment: .bodyweight, category: .strength),
                    ExerciseDefinition(name: "Lat Pulldown", primaryMuscle: "Lats", secondaryMuscles: ["Biceps"], equipment: .cable, category: .strength),
                    ExerciseDefinition(name: "Barbell Row", primaryMuscle: "Back", secondaryMuscles: ["Biceps", "Lats"], equipment: .barbell, category: .strength),
                    ExerciseDefinition(name: "Overhead Press", primaryMuscle: "Shoulders", secondaryMuscles: ["Triceps"], equipment: .barbell, category: .strength),
                    ExerciseDefinition(name: "Lateral Raise", primaryMuscle: "Shoulders", secondaryMuscles: [], equipment: .dumbbell, category: .strength),
                    ExerciseDefinition(name: "Bicep Curl", primaryMuscle: "Biceps", secondaryMuscles: [], equipment: .dumbbell, category: .strength),
                    ExerciseDefinition(name: "Tricep Extension", primaryMuscle: "Triceps", secondaryMuscles: [], equipment: .cable, category: .strength),
                    ExerciseDefinition(name: "Leg Extension", primaryMuscle: "Quadriceps", secondaryMuscles: [], equipment: .machine, category: .strength),
                    ExerciseDefinition(name: "Leg Curl", primaryMuscle: "Hamstrings", secondaryMuscles: [], equipment: .machine, category: .strength),
                    ExerciseDefinition(name: "Calf Raise", primaryMuscle: "Calves", secondaryMuscles: [], equipment: .machine, category: .strength),
                    ExerciseDefinition(name: "Crunch", primaryMuscle: "Core", secondaryMuscles: [], equipment: .bodyweight, category: .strength),
                    ExerciseDefinition(name: "Plank", primaryMuscle: "Core", secondaryMuscles: [], equipment: .bodyweight, category: .strength)
                ]
                for ex in initial {
                    if !existing.contains(where: { $0.name == ex.name }) {
                        context.insert(ex)
                    }
                }
                try context.save()
            }
        } catch {
            print("Failed to seed exercises: \(error)")
        }
    }
}
