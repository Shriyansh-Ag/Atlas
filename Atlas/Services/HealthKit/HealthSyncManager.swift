import Foundation
import HealthKit
import SwiftData
import Combine

@MainActor
public final class HealthSyncManager: ObservableObject {
    public static let shared = HealthSyncManager()
    
    private let repo = HealthSampleRepository()
    @Published public var isSyncing = false
    @Published public var lastSyncDate: Date? = nil
    @Published public var lastSyncError: String? = nil
    
    private init() {}
    
    public func sync(context: ModelContext) async {
        guard !isSyncing else { return }
        
        isSyncing = true
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let now = Date()
        
        // Fetch steps
        if let steps = try? await repo.fetchCumulativeSum(for: .stepCount, from: startOfDay, to: now) {
            save(metric: .steps, value: steps, unit: "steps", date: startOfDay, context: context)
        }
        
        // Fetch Resting HR
        if let rhr = try? await repo.fetchLatestQuantity(for: .restingHeartRate) {
            save(metric: .restingHeartRate, value: rhr.value, unit: "bpm", date: startOfDay, context: context)
        }
        
        // Fetch VO2 Max
        if let vo2 = try? await repo.fetchLatestQuantity(for: .vo2Max) {
            save(metric: .vo2Max, value: vo2.value, unit: "ml/kg/min", date: startOfDay, context: context)
        }
        
        // Fetch Weight
        if let weight = try? await repo.fetchLatestQuantity(for: .bodyMass) {
            save(metric: .weight, value: weight.value, unit: "kg", date: startOfDay, context: context)
        }
        
        // Fetch Water
        if let water = try? await repo.fetchCumulativeSum(for: .dietaryWater, from: startOfDay, to: now) {
            save(metric: .waterIntake, value: water, unit: "L", date: startOfDay, context: context)
        }
        
        // Fetch HRV
        if let hrv = try? await repo.fetchLatestQuantity(for: .heartRateVariabilitySDNN) {
            save(metric: .hrv, value: hrv.value, unit: "ms", date: startOfDay, context: context)
        }
        
        // Fetch Sleep
        var components = Calendar.current.dateComponents([.year, .month, .day], from: startOfDay)
        components.day! -= 1
        components.hour = 18
        let yesterdayEvening = Calendar.current.date(from: components)!
        
        do {
            let sleepSamples = try await repo.fetchSleepAnalysis(from: yesterdayEvening, to: now)
            let sleepScore = SleepScoreCalculator.calculate(from: sleepSamples)
            save(metric: .sleepScore, value: sleepScore, unit: "score", date: startOfDay, context: context)
            lastSyncError = nil
        } catch {
            // A failed fetch (e.g. denied sleep-data permission) must not be conflated
            // with "user genuinely has 0 minutes of sleep" — surface it distinctly so the
            // UI/logs can tell the difference instead of silently showing a 0 score.
            lastSyncError = "Sleep data unavailable: \(error.localizedDescription)"
            print("⚠️ Failed to fetch sleep analysis: \(error)")
        }
        
        // Calculate Recovery
        let sleep = fetchLatestValue(for: .sleepScore, context: context) ?? 0
        let restingHR = fetchLatestValue(for: .restingHeartRate, context: context) ?? 0
        let hrvValue = fetchLatestValue(for: .hrv, context: context) ?? 0
        let recovery = RecoveryScoreCalculator.calculate(
            sleepScore: sleep,
            restingHR: restingHR,
            hrv: hrvValue,
            yesterdayActivityCalories: 0 // Mocked for now
        )
        save(metric: .recoveryScore, value: recovery, unit: "%", date: startOfDay, context: context)
        
        do {
            try context.save()
            lastSyncDate = Date()
            print("✅ Successfully synced HealthKit metrics to SwiftData.")
        } catch {
            print("❌ Failed to save synced metrics to SwiftData: \(error)")
        }
        
        isSyncing = false
    }
    
    private func save(metric: HealthMetricType, value: Double, unit: String, date: Date, context: ModelContext) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let id = "\(metric.rawValue)_\(dateString)"
        
        // Find existing
        var descriptor = FetchDescriptor<CachedHealthMetric>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        
        if let existing = try? context.fetch(descriptor).first {
            existing.value = value
            existing.unit = unit
            existing.date = Date() // Update timestamp
        } else {
            // Use the same `date` the id/descriptor above were derived from, not a fresh
            // `Date()` call — otherwise a sync running near local midnight can compute a
            // different day-string here than the one used for lookup, silently forking
            // a duplicate row for the same logical day.
            let newMetric = CachedHealthMetric(type: metric, value: value, date: date, unit: unit)
            context.insert(newMetric)
        }
    }
    
    private func fetchLatestValue(for metric: HealthMetricType, context: ModelContext) -> Double? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Calendar.current.startOfDay(for: Date()))
        let id = "\(metric.rawValue)_\(dateString)"
        
        var descriptor = FetchDescriptor<CachedHealthMetric>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        
        return try? context.fetch(descriptor).first?.value
    }
}
