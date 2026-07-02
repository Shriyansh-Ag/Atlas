import Foundation
import Observation

/// The main Dependency Injection container for the application.
/// It holds references to all core services and managers.
@Observable
public final class AppEnvironment: @unchecked Sendable {
    public var router: Router
    // Services will be added here
    // public let healthService: HealthServiceProtocol
    // public let nutritionService: NutritionServiceProtocol
    
    public init(router: Router = Router()) {
        self.router = router
    }
    
    public static var preview: AppEnvironment {
        AppEnvironment()
    }
}
