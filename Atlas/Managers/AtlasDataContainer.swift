import Foundation
import SwiftData
import SwiftUI

@MainActor
public class AtlasDataContainer {
    public static let shared = AtlasDataContainer()
    
    public let container: ModelContainer
    
    private init() {
        let schema = Schema([
            UserProfile.self,
            CachedHealthMetric.self,
            FoodItem.self,
            MealItem.self,
            MealLog.self,
            Recipe.self,
            RecipeIngredient.self,
            ExerciseDefinition.self,
            WorkoutPlan.self,
            WorkoutPlanDay.self,
            PlannedExercise.self,
            PlannedSet.self,
            WorkoutSession.self,
            LoggedExercise.self,
            LoggedSet.self,
            AIFoodCorrection.self,
            AtlasObjective.self,
            BodyMeasurement.self,
            ProgressPhoto.self,
            NotificationPreferences.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false, // Persist to disk
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
