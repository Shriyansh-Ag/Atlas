import SwiftUI
import WidgetKit

// MARK: - Calories Widget

struct CaloriesWidget: Widget {
    let kind = "AtlasCaloriesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaloriesTimelineProvider()) { entry in
            CaloriesWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calories")
        .description("Track your daily calorie intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline

struct CaloriesEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataSnapshot
}

struct CaloriesTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaloriesEntry {
        CaloriesEntry(date: .now, snapshot: SharedDataSnapshot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CaloriesEntry) -> Void) {
        completion(CaloriesEntry(date: .now, snapshot: SharedDataStore.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CaloriesEntry>) -> Void) {
        let snapshot = SharedDataStore.load()
        let entry = CaloriesEntry(date: .now, snapshot: snapshot)
        // ponytail: refresh every 30 min. WidgetKit will throttle if needed.
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Views

struct CaloriesWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CaloriesEntry
    
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
            ZStack {
                WidgetProgressRing(
                    progress: entry.snapshot.calorieProgress,
                    color: .blue,
                    size: 70,
                    lineWidth: 8
                )
                VStack(spacing: 0) {
                    Text("\(Int(entry.snapshot.caloriesRemaining))")
                        .font(.title3.weight(.bold))
                        .minimumScaleFactor(0.6)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Text("remaining")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var mediumView: some View {
        HStack(spacing: 16) {
            // Left: calorie ring
            ZStack {
                WidgetProgressRing(
                    progress: entry.snapshot.calorieProgress,
                    color: .blue,
                    size: 80,
                    lineWidth: 10
                )
                VStack(spacing: 0) {
                    Text("\(Int(entry.snapshot.caloriesRemaining))")
                        .font(.title2.weight(.bold))
                        .minimumScaleFactor(0.6)
                    Text("kcal left")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Right: macros
            VStack(spacing: 8) {
                WidgetMacroBar(label: "Protein", current: entry.snapshot.proteinConsumed, target: entry.snapshot.proteinTarget, color: .blue)
                WidgetMacroBar(label: "Carbs", current: entry.snapshot.carbsConsumed, target: entry.snapshot.carbsTarget, color: .orange)
                WidgetMacroBar(label: "Fat", current: entry.snapshot.fatConsumed, target: entry.snapshot.fatTarget, color: .purple)
            }
        }
        .padding(4)
    }
}
