import Foundation
import SwiftData

/// Represents both a Goal and a Challenge in Atlas.
/// A Challenge is simply a Goal with `isChallenge = true`, representing
/// a predefined or fixed-duration community-style milestone.
@Model
public class AtlasObjective {
    @Attribute(.unique) public var id: String
    public var title: String
    public var typeRawValue: String
    
    public var targetValue: Double
    public var startDate: Date
    public var targetDate: Date
    
    public var isChallenge: Bool
    public var reminderEnabled: Bool
    
    public var notes: String?
    
    public var milestones: [String] = [] // e.g. "50%", "75%", "Completed"
    public var isCompleted: Bool = false
    
    public var type: ObjectiveType {
        get { ObjectiveType(rawValue: typeRawValue) ?? .custom }
        set { typeRawValue = newValue.rawValue }
    }
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        type: ObjectiveType,
        targetValue: Double,
        startDate: Date = Date(),
        targetDate: Date,
        isChallenge: Bool = false,
        reminderEnabled: Bool = true,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.typeRawValue = type.rawValue
        self.targetValue = targetValue
        self.startDate = startDate
        self.targetDate = targetDate
        self.isChallenge = isChallenge
        self.reminderEnabled = reminderEnabled
        self.notes = notes
    }
}

public enum ObjectiveType: String, Codable, CaseIterable {
    case weightLoss
    case weightGain
    case maintainWeight
    case targetBodyFat
    case proteinGoal
    case waterGoal
    case stepGoal
    case sleepGoal
    case workoutConsistency // e.g. workouts per week
    case custom
}

/// Stores granular notification preferences.
@Model
public class NotificationPreferences {
    @Attribute(.unique) public var id: String = "shared_preferences"
    
    public var workoutReminders: Bool = true
    public var mealReminders: Bool = true
    public var waterReminders: Bool = true
    public var proteinReminders: Bool = true
    public var sleepReminders: Bool = true
    public var goalUpdates: Bool = true
    
    public var quietHoursStartHour: Int = 22 // 10 PM
    public var quietHoursEndHour: Int = 7   // 7 AM
    public var enableWeekendReminders: Bool = true
    
    public init() {}
}
