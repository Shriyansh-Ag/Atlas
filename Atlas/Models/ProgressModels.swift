import Foundation
import SwiftData

// MARK: - Progress Photos

public enum PhotoType: String, Codable, CaseIterable {
    case front = "Front"
    case side = "Side"
    case back = "Back"
    case custom = "Custom"
}

@Model
public class ProgressPhoto {
    @Attribute(.unique) public var id: String
    public var date: Date
    public var typeRawValue: String
    public var localImagePath: String
    
    public var type: PhotoType {
        get { PhotoType(rawValue: typeRawValue) ?? .front }
        set { typeRawValue = newValue.rawValue }
    }
    
    public init(id: String = UUID().uuidString, date: Date = Date(), type: PhotoType = .front, localImagePath: String) {
        self.id = id
        self.date = date
        self.typeRawValue = type.rawValue
        self.localImagePath = localImagePath
    }
}

// MARK: - Body Measurements

@Model
public class BodyMeasurement {
    @Attribute(.unique) public var id: String
    public var date: Date
    
    // Core Measurements (in cm or inches based on settings, standardizing on cm internally is best, but let's store doubles)
    public var neck: Double?
    public var chest: Double?
    public var waist: Double?
    public var hips: Double?
    public var shoulders: Double?
    
    // Limbs
    public var leftArm: Double?
    public var rightArm: Double?
    public var leftForearm: Double?
    public var rightForearm: Double?
    public var leftThigh: Double?
    public var rightThigh: Double?
    public var leftCalf: Double?
    public var rightCalf: Double?
    public var leftWrist: Double?
    public var rightWrist: Double?
    
    // Custom dictionary encoded as JSON string (Ponytail: Keep it simple without complex relationships)
    public var customMeasurementsJSON: String?
    
    public init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        neck: Double? = nil,
        chest: Double? = nil,
        waist: Double? = nil,
        hips: Double? = nil,
        shoulders: Double? = nil,
        leftArm: Double? = nil,
        rightArm: Double? = nil,
        leftForearm: Double? = nil,
        rightForearm: Double? = nil,
        leftThigh: Double? = nil,
        rightThigh: Double? = nil,
        leftCalf: Double? = nil,
        rightCalf: Double? = nil,
        leftWrist: Double? = nil,
        rightWrist: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.neck = neck
        self.chest = chest
        self.waist = waist
        self.hips = hips
        self.shoulders = shoulders
        self.leftArm = leftArm
        self.rightArm = rightArm
        self.leftForearm = leftForearm
        self.rightForearm = rightForearm
        self.leftThigh = leftThigh
        self.rightThigh = rightThigh
        self.leftCalf = leftCalf
        self.rightCalf = rightCalf
        self.leftWrist = leftWrist
        self.rightWrist = rightWrist
    }
}

// MARK: - Milestones (Computed, Not Persisted in SwiftData)

public enum MilestoneType: String, Equatable {
    case weightLost
    case bodyFat
    case workoutCount
    case streak
    case pr
}

public struct Milestone: Identifiable, Equatable {
    public var id = UUID()
    public var type: MilestoneType
    public var title: String
    public var subtitle: String
    public var icon: String
    public var dateAchieved: Date
    public var isRecent: Bool // Computed true if achieved in last 7 days
}

// MARK: - Personal Records (Computed, Not Persisted)

public struct PersonalRecord: Identifiable {
    public var id = UUID()
    public var exerciseName: String
    public var value: String // "100 kg x 5" or "105 kg 1RM"
    public var date: Date
    public var category: PRCategory
    
    public enum PRCategory {
        case weight
        case volume
        case streak
        case time
    }
}
