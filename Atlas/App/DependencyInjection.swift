import SwiftUI

/// Environment key for AppEnvironment to allow dependency injection via SwiftUI Environment
private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = AppEnvironment()
}

public extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
