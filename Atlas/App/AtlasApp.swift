import SwiftUI
import SwiftData

@main
struct AtlasApp: App {
    @State private var environment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $environment.router.path) {
                SplashView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .dashboard:
                            MainTabView()
                        case .settings:
                            SettingsView()
                        case .onboarding:
                            OnboardingView()
                        case .profileSettings:
                            ProfileSettingsView()
                        case .healthKitAuthorization:
                            HealthKitAuthorizationView()
                        default:
                            EmptyView()
                        }
                    }
                    .sheet(item: $environment.router.presentedSheet) { route in
                        // Handle sheet presentation based on route
                        EmptyView()
                    }
                    .fullScreenCover(item: $environment.router.presentedFullScreenCover) { route in
                        // Handle full screen presentation based on route
                        EmptyView()
                    }
            }
            .environment(\.appEnvironment, environment)
            .environment(\.colorScheme, .dark) // Force dark mode across the app
            .modelContainer(AtlasDataContainer.shared.container)
        }
    }
}

// Extention to support Route as Identifiable for Sheets and FullScreenCovers
extension Route: Identifiable {
    public var id: Int { hashValue }
}
