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
            CachedHealthMetric.self
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
