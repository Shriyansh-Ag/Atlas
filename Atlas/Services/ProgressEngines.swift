import Foundation
import SwiftData
import SwiftUI

/// Facade for all progress operations
public class ProgressService {
    public static let shared = ProgressService()
    private init() {}
}

/// Computes body composition metrics like lean mass and fat mass
public struct BodyCompositionEngine {
    public static func calculateLeanMass(weight: Double, bodyFatPercentage: Double) -> Double {
        return weight * (1.0 - (bodyFatPercentage / 100.0))
    }
    
    public static func calculateFatMass(weight: Double, bodyFatPercentage: Double) -> Double {
        return weight * (bodyFatPercentage / 100.0)
    }
}

/// Dynamically computes milestones without persisting them
public struct MilestoneEngine {
    public static func computeMilestones(context: ModelContext) -> [Milestone] {
        var milestones = [Milestone]()
        
        // Example: Check workout count
        let descriptor = FetchDescriptor<WorkoutSession>(predicate: #Predicate { $0.isCompleted == true })
        if let count = try? context.fetchCount(descriptor), count > 0 {
            if count >= 1 {
                milestones.append(Milestone(type: .workoutCount, title: "First Workout", subtitle: "You completed your first workout!", icon: "party.popper.fill", dateAchieved: Date(), isRecent: true))
            }
            if count >= 10 {
                milestones.append(Milestone(type: .workoutCount, title: "10 Workouts", subtitle: "Consistency is key.", icon: "flame.fill", dateAchieved: Date(), isRecent: true))
            }
        }
        
        // Add logic for weight lost, body fat, PRs as needed
        
        return milestones
    }
}

/// Computes weekly and monthly changes for weight and other metrics
public struct ProgressCalculator {
    public static func calculateWeightChange(context: ModelContext) -> (Double, String) {
        // Mocked for MVP
        return (-1.2, "Down 1.2kg this month")
    }
}

/// Manages photo storage on disk
public class PhotoTimelineManager {
    public static let shared = PhotoTimelineManager()
    
    private init() {}
    
    public func savePhoto(_ image: UIImage, type: PhotoType, date: Date, context: ModelContext) throws -> ProgressPhoto {
        let fileName = UUID().uuidString + ".jpg"
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documents.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "PhotoTimelineManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        try data.write(to: fileURL)
        
        let photo = ProgressPhoto(date: date, type: type, localImagePath: fileName)
        context.insert(photo)
        return photo
    }
    
    public func loadPhoto(from path: String) -> UIImage? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documents.appendingPathComponent(path)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

/// Minimal measurement persistence layer
public struct MeasurementManager {
    public static func fetchLatest(context: ModelContext) -> BodyMeasurement? {
        var descriptor = FetchDescriptor<BodyMeasurement>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
}

public struct TransformationEngine {
    public static func buildTimeline(context: ModelContext) -> [TransformationEvent] {
        return []
    }
}

public struct TransformationEvent: Identifiable {
    public var id = UUID()
    public var date: Date
    public var title: String
}
