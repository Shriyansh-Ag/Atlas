import Foundation
import HealthKit

public final class HealthSampleRepository: Sendable {
    private let healthStore = HealthKitService.shared.healthStore
    
    public init() {}
    
    // MARK: - Generic Reading
    
    public func fetchLatestQuantity(for typeIdentifier: HKQuantityTypeIdentifier) async throws -> (value: Double, unit: HKUnit, date: Date)? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else { return nil }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // We guess the unit based on type for simplicity here, but in a real app we'd map this carefully
                let unit = self.preferredUnit(for: typeIdentifier)
                continuation.resume(returning: (sample.quantity.doubleValue(for: unit), unit, sample.endDate))
            }
            healthStore.execute(query)
        }
    }
    
    public func fetchCumulativeSum(for typeIdentifier: HKQuantityTypeIdentifier, from startDate: Date, to endDate: Date) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else { return 0 }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sum = result?.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let unit = self.preferredUnit(for: typeIdentifier)
                continuation.resume(returning: sum.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }
    
    public func fetchSleepAnalysis(from startDate: Date, to endDate: Date) async throws -> [HKCategorySample] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }
    }
    
    public func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [HKWorkout] {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
            }
            healthStore.execute(query)
        }
    }
    
    // MARK: - Writing
    
    public func saveWeight(kg: Double, date: Date = Date()) async throws {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        
        try await healthStore.save(sample)
    }
    
    public func saveWorkout(startDate: Date, endDate: Date, activeEnergyBurnedKcal: Double?) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: nil)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            builder.beginCollection(withStart: startDate) { success, error in
                if let error = error { continuation.resume(throwing: error); return }
                
                if let kcal = activeEnergyBurnedKcal, let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                    let energy = HKQuantity(unit: .kilocalorie(), doubleValue: kcal)
                    let sample = HKQuantitySample(type: type, quantity: energy, start: startDate, end: endDate)
                    builder.add([sample]) { success, error in
                        if let error = error { continuation.resume(throwing: error); return }
                        builder.endCollection(withEnd: endDate) { success, error in
                            if let error = error { continuation.resume(throwing: error); return }
                            builder.finishWorkout { workout, error in
                                if let error = error { continuation.resume(throwing: error); return }
                                continuation.resume()
                            }
                        }
                    }
                } else {
                    builder.endCollection(withEnd: endDate) { success, error in
                        if let error = error { continuation.resume(throwing: error); return }
                        builder.finishWorkout { workout, error in
                            if let error = error { continuation.resume(throwing: error); return }
                            continuation.resume()
                        }
                    }
                }
            }
        }

    }
    
    // MARK: - Helper
    
    private func preferredUnit(for typeIdentifier: HKQuantityTypeIdentifier) -> HKUnit {
        switch typeIdentifier {
        case .stepCount, .flightsClimbed:
            return HKUnit.count()
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage:
            return HKUnit.count().unitDivided(by: .minute())
        case .bodyMass, .leanBodyMass:
            return HKUnit.gramUnit(with: .kilo)
        case .height, .distanceWalkingRunning, .distanceCycling:
            return HKUnit.meter()
        case .activeEnergyBurned, .basalEnergyBurned:
            return HKUnit.kilocalorie()
        case .appleExerciseTime, .appleStandTime:
            return HKUnit.minute()
        case .dietaryWater:
            return HKUnit.liter()
        case .bodyFatPercentage, .oxygenSaturation:
            return HKUnit.percent()
        case .vo2Max:
            let ml = HKUnit.literUnit(with: .milli)
            let kgMin = HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute())
            return ml.unitDivided(by: kgMin)
        case .heartRateVariabilitySDNN:
            return HKUnit.secondUnit(with: .milli)
        default:
            return HKUnit.count()
        }
    }
}
