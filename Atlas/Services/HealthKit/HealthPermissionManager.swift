import Foundation
import HealthKit
import Combine

@MainActor
public class HealthPermissionManager: ObservableObject {
    @Published public var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published public var isRequesting: Bool = false
    @Published public var error: String? = nil
    
    private let service: HealthKitService
    
    public init(service: HealthKitService? = nil) {
        self.service = service ?? .shared
        self.updateStatus()
    }
    
    public func requestPermissions() async {
        isRequesting = true
        error = nil
        
        do {
            try await service.requestAuthorization()
            self.updateStatus()
        } catch {
            self.error = error.localizedDescription
        }
        
        isRequesting = false
    }
    
    public func updateStatus() {
        // We use step count as a proxy for general HealthKit read authorization status
        // because HealthKit doesn't provide a global "is authorized" flag.
        self.authorizationStatus = service.checkPermission(for: .stepCount)
    }
}
