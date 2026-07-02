import Foundation
import HealthKit

public enum HealthKitError: Error {
    case healthDataNotAvailable
    case permissionDenied
    case unexpectedType
    case queryFailed(Error)
    case notConfigured
}

public final class HealthKitService: Sendable {
    public static let shared = HealthKitService()
    public let healthStore = HKHealthStore()
    
    private init() {}
    
    public var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    public var readTypes: Set<HKObjectType> {
        let types: [HKObjectType?] = [
            // Characteristics
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            
            // Body Measurements
            HKObjectType.quantityType(forIdentifier: .height),
            HKObjectType.quantityType(forIdentifier: .bodyMass),
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage),
            HKObjectType.quantityType(forIdentifier: .leanBodyMass),
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            
            // Vitals
            HKObjectType.quantityType(forIdentifier: .heartRate),
            HKObjectType.quantityType(forIdentifier: .restingHeartRate),
            HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage),
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            HKObjectType.quantityType(forIdentifier: .vo2Max),
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
            HKObjectType.quantityType(forIdentifier: .respiratoryRate),
            
            // Mobility
            HKObjectType.quantityType(forIdentifier: .walkingSpeed),
            HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage),
            HKObjectType.quantityType(forIdentifier: .walkingStepLength),
            HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage),
            
            // Activity
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKObjectType.quantityType(forIdentifier: .distanceCycling),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
            HKObjectType.quantityType(forIdentifier: .appleStandTime),
            HKObjectType.quantityType(forIdentifier: .flightsClimbed),
            
            // Categories
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            HKObjectType.categoryType(forIdentifier: .mindfulSession),
            
            // Workouts & Nutrition
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .dietaryWater)
        ]
        
        return Set(types.compactMap { $0 })
    }
    
    public var writeTypes: Set<HKSampleType> {
        let types: [HKSampleType?] = [
            HKObjectType.quantityType(forIdentifier: .bodyMass),
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage),
            HKObjectType.quantityType(forIdentifier: .dietaryWater),
            HKObjectType.workoutType()
        ]
        
        return Set(types.compactMap { $0 })
    }
    
    public func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitError.healthDataNotAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }
    
    public func checkPermission(for typeIdentifier: HKQuantityTypeIdentifier) -> HKAuthorizationStatus {
        guard let type = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
            return .notDetermined
        }
        return healthStore.authorizationStatus(for: type)
    }
}
