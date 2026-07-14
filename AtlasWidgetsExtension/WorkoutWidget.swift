import SwiftUI
import WidgetKit

// MARK: - Workout Widget

struct WorkoutWidget: Widget {
    let kind = "AtlasWorkoutWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutTimelineProvider()) { entry in
            WorkoutWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Workout")
        .description("See today's workout at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline

struct WorkoutEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataSnapshot
}

struct WorkoutTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorkoutEntry {
        WorkoutEntry(date: .now, snapshot: SharedDataSnapshot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WorkoutEntry) -> Void) {
        completion(WorkoutEntry(date: .now, snapshot: SharedDataStore.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutEntry>) -> Void) {
        let entry = WorkoutEntry(date: .now, snapshot: SharedDataStore.load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Views

struct WorkoutWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: WorkoutEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }
    
    private var smallView: some View {
        VStack(spacing: 8) {
            Image(systemName: "dumbbell.fill")
                .font(.title2)
                .foregroundStyle(.purple)
            
            if let name = entry.snapshot.activeWorkoutName {
                Text(name)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text("In Progress")
                    .font(.caption2)
                    .foregroundStyle(.green)
            } else if let next = entry.snapshot.nextWorkoutName {
                Text(next)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text("Up Next")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else if entry.snapshot.todayWorkoutMinutes > 0 {
                Text("\(entry.snapshot.todayWorkoutMinutes) min")
                    .font(.title3.weight(.bold))
                Text("completed")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Rest Day")
                    .font(.caption.weight(.semibold))
                Text("No workout planned")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(.purple)
                    Text("Today's Workout")
                        .font(.subheadline.weight(.semibold))
                }
                
                if entry.snapshot.todayWorkoutMinutes > 0 {
                    WidgetMetricRow(icon: "clock", title: "Duration", value: "\(entry.snapshot.todayWorkoutMinutes) min", color: .blue)
                    WidgetMetricRow(icon: "flame", title: "Calories", value: "\(Int(entry.snapshot.todayWorkoutCalories)) kcal", color: .orange)
                } else {
                    Text("No workouts logged today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if entry.snapshot.todayWorkoutMinutes > 0 {
                WidgetProgressRing(
                    progress: min(Double(entry.snapshot.todayWorkoutMinutes) / 60.0, 1.0),
                    color: .purple,
                    size: 60,
                    lineWidth: 8
                )
            }
        }
        .padding(4)
    }
}
