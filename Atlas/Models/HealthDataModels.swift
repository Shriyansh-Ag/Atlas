import Foundation
import SwiftData

public enum HealthMetricType: String, Codable, CaseIterable {
    case steps
    case heartRate
    case restingHeartRate
    case walkingHeartRate
    case hrv
    case vo2Max
    case bloodOxygen
    case respiratoryRate
    
    // Body Measurements
    case weight
    case bodyFatPercentage
    case leanBodyMass
    case bmi
    case height
    
    // Energy & Activity
    case activeEnergyBurned
    case basalEnergyBurned
    case exerciseMinutes
    case standMinutes
    case flightsClimbed
    
    // Distances
    case distanceWalking
    case distanceRunning
    case distanceCycling
    
    // Mobility
    case walkingSpeed
    case walkingAsymmetry
    case walkingStepLength
    case walkingDoubleSupport
    
    // Sleep & Mindfulness
    case sleepScore
    case sleepDuration
    case mindfulnessMinutes
    
    // Nutrition
    case waterIntake
    case dietaryCalories
    
    // Custom Computed
    case recoveryScore
}

@Model
public class CachedHealthMetric {
    @Attribute(.unique) public var id: String
    public var type: HealthMetricType
    public var value: Double
    public var date: Date
    public var unit: String
    
    public init(type: HealthMetricType, value: Double, date: Date, unit: String) {
        // Create a unique ID based on type and day (assuming 1 value per day per type in the cache)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        self.id = "\(type.rawValue)_\(dateString)"
        self.type = type
        self.value = value
        self.date = date
        self.unit = unit
    }
}
