import SwiftUI
import WidgetKit

// MARK: - Dashboard Widget (Large)

struct DashboardWidget: Widget {
    let kind = "AtlasDashboardWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DashboardTimelineProvider()) { entry in
            DashboardWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Dashboard")
        .description("Your complete daily overview.")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Timeline

struct DashboardEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataSnapshot
}

struct DashboardTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DashboardEntry {
        DashboardEntry(date: .now, snapshot: SharedDataSnapshot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DashboardEntry) -> Void) {
        completion(DashboardEntry(date: .now, snapshot: SharedDataStore.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DashboardEntry>) -> Void) {
        let entry = DashboardEntry(date: .now, snapshot: SharedDataStore.load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - View

struct DashboardWidgetView: View {
    let entry: DashboardEntry
    
    private var s: SharedDataSnapshot { entry.snapshot }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text("Atlas")
                    .font(.headline.weight(.bold))
                Spacer()
                Text(entry.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Nutrition row
            HStack(spacing: 12) {
                ZStack {
                    WidgetProgressRing(progress: s.calorieProgress, color: .blue, size: 56, lineWidth: 7)
                    VStack(spacing: 0) {
                        Text("\(Int(s.caloriesRemaining))")
                            .font(.caption.weight(.bold))
                            .minimumScaleFactor(0.6)
                        Text("kcal")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(spacing: 5) {
                    WidgetMacroBar(label: "P", current: s.proteinConsumed, target: s.proteinTarget, color: .blue)
                    WidgetMacroBar(label: "C", current: s.carbsConsumed, target: s.carbsTarget, color: .orange)
                    WidgetMacroBar(label: "F", current: s.fatConsumed, target: s.fatTarget, color: .purple)
                }
            }
            
            Divider()
            
            // Health metrics grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                compactMetric(icon: "figure.walk", value: "\(s.steps)", label: "Steps", color: .blue)
                compactMetric(icon: "bed.double.fill", value: "\(s.sleepScore)", label: "Sleep", color: .indigo)
                compactMetric(icon: "heart.fill", value: "\(s.restingHeartRate)", label: "HR", color: .red)
                compactMetric(icon: "drop.fill", value: String(format: "%.1f", s.waterIntake), label: "Water", color: .cyan)
                compactMetric(icon: "scalemass.fill", value: String(format: "%.1f", s.bodyWeight), label: "kg", color: .green)
                compactMetric(icon: "lungs.fill", value: String(format: "%.0f", s.vo2Max), label: "VO2", color: .orange)
            }
            
            Divider()
            
            // Workout + Streak
            HStack {
                if s.todayWorkoutMinutes > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dumbbell.fill")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                        Text("\(s.todayWorkoutMinutes) min · \(Int(s.todayWorkoutCalories)) kcal")
                            .font(.caption2)
                    }
                } else {
                    Text("No workout today")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                WidgetStreakDots(streak: s.currentStreak)
            }
        }
        .padding(2)
    }
    
    private func compactMetric(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
    }
}
