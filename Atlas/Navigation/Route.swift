import SwiftUI

public enum Route: Hashable {
    case dashboard
    case nutrition
    case workout
    case progress
    case recovery
    case settings
    case onboarding
    case profileSettings
    case healthKitAuthorization
    case aiSettings
    case notificationSettings
    case goals
    
    // Feature-specific nested routes can be added here
    // e.g. case workoutDetail(id: String)
}
