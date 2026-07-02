import Foundation
import SwiftData
import Combine

@MainActor
public class WorkoutSessionManager: ObservableObject {
    public static let shared = WorkoutSessionManager()
    
    @Published public var activeSession: WorkoutSession?
    @Published public var isWorkoutActive = false
    @Published public var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    
    private init() {}
    
    public func startWorkout(name: String = "Freestyle Workout", context: ModelContext) {
        let session = WorkoutSession(name: name)
        context.insert(session)
        do {
            try context.save()
            self.activeSession = session
            self.isWorkoutActive = true
            self.elapsedTime = 0
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.elapsedTime += 1
                }
            }
        } catch {
            print("Failed to start workout: \(error)")
        }
    }
    
    public func addExercise(_ exercise: ExerciseDefinition, context: ModelContext) {
        guard let session = activeSession else { return }
        let order = session.exercises.count
        let loggedEx = LoggedExercise(exercise: exercise, order: order)
        loggedEx.session = session
        session.exercises.append(loggedEx)
        
        // Add a default set
        addSet(to: loggedEx, context: context)
    }
    
    public func addSet(to exercise: LoggedExercise, context: ModelContext) {
        let order = exercise.sets.count
        let previousSet = exercise.sets.last
        let weight = previousSet?.weight ?? 0
        let reps = previousSet?.reps ?? 0
        
        let newSet = LoggedSet(order: order, reps: reps, weight: weight)
        newSet.loggedExercise = exercise
        exercise.sets.append(newSet)
        
        try? context.save()
    }
    
    public func finishWorkout(context: ModelContext) {
        guard let session = activeSession else { return }
        session.endDate = Date()
        session.isCompleted = true
        
        timer?.invalidate()
        timer = nil
        self.isWorkoutActive = false
        self.activeSession = nil
        self.elapsedTime = 0
        
        try? context.save()
        
        // Sync to HealthKit
        let startDate = session.startDate
        let endDate = session.endDate ?? Date()
        let calories = session.totalCalories
        Task {
            do {
                try await HealthSampleRepository().saveWorkout(startDate: startDate, endDate: endDate, activeEnergyBurnedKcal: calories)
            } catch {
                print("Failed to sync workout to HealthKit: \(error)")
            }
        }
    }
    
    public func discardWorkout(context: ModelContext) {
        if let session = activeSession {
            context.delete(session)
            try? context.save()
        }
        
        timer?.invalidate()
        timer = nil
        self.isWorkoutActive = false
        self.activeSession = nil
        self.elapsedTime = 0
    }
}
