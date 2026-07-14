import Foundation
import HealthKit

public class SleepScoreCalculator {
    /// Calculates a sleep score from 0-100 based on HealthKit sleep samples.
    public static func calculate(from samples: [HKCategorySample]) -> Double {
        let sleepValues = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]
        
        let sleepSamples = samples.filter { sleepValues.contains($0.value) }
        let deepSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue }
        let remSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
        let awakeSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.awake.rawValue }
        
        let totalSleepMinutes = calculateDuration(for: sleepSamples)
        let awakeMinutes = calculateDuration(for: awakeSamples)
        
        // Base score on duration (Target: 8 hours = 480 mins)
        let durationScore = min((totalSleepMinutes / 480.0) * 50, 50)
        
        // Base score on quality (deep + rem should be ~40% of total).
        // Deep and REM intervals are merged together (not summed independently) before
        // dividing, so overlapping/duplicate stage samples from multiple data sources
        // can't push the ratio above what totalSleepMinutes actually supports.
        let qualityScore: Double
        if totalSleepMinutes > 0 {
            let qualityMinutes = calculateDuration(for: deepSamples + remSamples)
            let qualityRatio = qualityMinutes / totalSleepMinutes
            qualityScore = min((qualityRatio / 0.4) * 40, 40)
        } else {
            qualityScore = 0
        }
        
        // Penalty for waking up a lot
        let awakePenalty = min((awakeMinutes / 60.0) * 10, 10)
        
        // NOTE: no artificial base bias here. The score is the sum of its earned
        // components only, clamped to [0, 100].
        let finalScore = max(0, min(100, durationScore + qualityScore - awakePenalty))
        
        return totalSleepMinutes > 60 ? finalScore : 0
    }
    
    private static func calculateDuration(for samples: [HKCategorySample]) -> Double {
        let intervals = samples.map { DateInterval(start: $0.startDate, end: $0.endDate) }
        return merge(intervals).reduce(0) { $0 + $1.duration } / 60.0
    }
    
    private static func merge(_ intervals: [DateInterval]) -> [DateInterval] {
        guard !intervals.isEmpty else { return [] }
        let sorted = intervals.sorted { $0.start < $1.start }
        var merged: [DateInterval] = [sorted[0]]
        
        for i in 1..<sorted.count {
            let current = sorted[i]
            guard let last = merged.last else { continue }
            
            if current.start <= last.end {
                if current.end > last.end {
                    merged[merged.count - 1] = DateInterval(start: last.start, end: current.end)
                }
            } else {
                merged.append(current)
            }
        }
        return merged
    }
}
