import Foundation

public class RecoveryScoreCalculator {
    
    /// Calculates a recovery score from 0-100 based on core metrics.
    public static func calculate(
        sleepScore: Double,
        restingHR: Double,
        hrv: Double,
        yesterdayActivityCalories: Double
    ) -> Double {
        
        // In a real app, these baselines would be calculated over a 30-day average per user.
        // We use typical healthy adult defaults here.
        let baselineRHR = 60.0
        let baselineHRV = 65.0
        
        // 1. Sleep Contribution (Max 40 points)
        let sleepComponent = (sleepScore / 100.0) * 40.0
        
        // 2. RHR Contribution (Max 30 points)
        // Lower RHR is better. If RHR is higher than baseline, subtract points.
        var rhrComponent = 30.0
        if restingHR > 0 {
            let rhrDiff = restingHR - baselineRHR
            rhrComponent = max(0, 30.0 - (rhrDiff * 2.0))
        }
        
        // 3. HRV Contribution (Max 30 points)
        // Higher HRV is better.
        var hrvComponent = 30.0
        if hrv > 0 {
            let hrvDiff = baselineHRV - hrv
            if hrvDiff > 0 {
                hrvComponent = max(0, 30.0 - (hrvDiff * 1.5))
            }
        }
        
        // 4. Activity Penalty (Optional)
        // If they burned a massive amount of calories yesterday, recovery should be lower today.
        var activityPenalty = 0.0
        if yesterdayActivityCalories > 1000 {
            activityPenalty = min(15.0, (yesterdayActivityCalories - 1000) / 100)
        }
        
        let finalScore = max(0, min(100, sleepComponent + rhrComponent + hrvComponent - activityPenalty))
        return finalScore
    }
}
