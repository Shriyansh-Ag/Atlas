import SwiftUI
import WidgetKit

// MARK: - Lock Screen Widgets

struct LockScreenCaloriesWidget: Widget {
    let kind = "AtlasLockScreenCalories"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenTimelineProvider()) { entry in
            LockScreenCaloriesView(entry: entry)
        }
        .configurationDisplayName("Calories")
        .description("Calories remaining on your Lock Screen.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct LockScreenStepsWidget: Widget {
    let kind = "AtlasLockScreenSteps"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenTimelineProvider()) { entry in
            LockScreenStepsView(entry: entry)
        }
        .configurationDisplayName("Steps")
        .description("Step count on your Lock Screen.")
        .supportedFamilies([.accessoryInline, .accessoryCircular])
    }
}

struct LockScreenProteinWidget: Widget {
    let kind = "AtlasLockScreenProtein"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenTimelineProvider()) { entry in
            LockScreenProteinView(entry: entry)
        }
        .configurationDisplayName("Protein")
        .description("Protein progress on your Lock Screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct LockScreenStreakWidget: Widget {
    let kind = "AtlasLockScreenStreak"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenTimelineProvider()) { entry in
            LockScreenStreakView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Your training streak on the Lock Screen.")
        .supportedFamilies([.accessoryInline, .accessoryCircular])
    }
}

// MARK: - Shared Timeline

struct LockScreenEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataSnapshot
}

struct LockScreenTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScreenEntry {
        LockScreenEntry(date: .now, snapshot: SharedDataSnapshot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LockScreenEntry) -> Void) {
        completion(LockScreenEntry(date: .now, snapshot: SharedDataStore.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScreenEntry>) -> Void) {
        let entry = LockScreenEntry(date: .now, snapshot: SharedDataStore.load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Calories Views

struct LockScreenCaloriesView: View {
    @Environment(\.widgetFamily) var family
    let entry: LockScreenEntry
    
    var body: some View {
        switch family {
        case .accessoryInline:
            Label("\(Int(entry.snapshot.caloriesRemaining)) kcal left", systemImage: "flame")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text("\(Int(entry.snapshot.caloriesRemaining))")
                        .font(.headline.weight(.bold))
                        .minimumScaleFactor(0.6)
                    Text("kcal")
                        .font(.system(size: 9))
                }
            }
            .widgetLabel {
                Gauge(value: entry.snapshot.calorieProgress) {
                    Text("Cal")
                }
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("Calories")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(Int(entry.snapshot.caloriesRemaining)) kcal remaining")
                    .font(.headline.weight(.semibold))
                    .minimumScaleFactor(0.7)
                Gauge(value: entry.snapshot.calorieProgress) { }
                    .gaugeStyle(.linearCapacity)
                    .tint(.blue)
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Steps Views

struct LockScreenStepsView: View {
    @Environment(\.widgetFamily) var family
    let entry: LockScreenEntry
    
    var body: some View {
        switch family {
        case .accessoryInline:
            Label("\(entry.snapshot.steps) steps", systemImage: "figure.walk")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: "figure.walk")
                        .font(.caption)
                    Text("\(entry.snapshot.steps)")
                        .font(.caption.weight(.bold))
                        .minimumScaleFactor(0.6)
                }
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Protein Views

struct LockScreenProteinView: View {
    @Environment(\.widgetFamily) var family
    let entry: LockScreenEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: entry.snapshot.proteinProgress) {
                Image(systemName: "p.circle")
            } currentValueLabel: {
                Text("\(Int(entry.snapshot.proteinConsumed))")
                    .font(.caption2.weight(.bold))
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("Protein")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(Int(entry.snapshot.proteinConsumed))/\(Int(entry.snapshot.proteinTarget))g")
                    .font(.headline.weight(.semibold))
                Gauge(value: entry.snapshot.proteinProgress) { }
                    .gaugeStyle(.linearCapacity)
                    .tint(.blue)
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Streak Views

struct LockScreenStreakView: View {
    @Environment(\.widgetFamily) var family
    let entry: LockScreenEntry
    
    var body: some View {
        switch family {
        case .accessoryInline:
            Label("\(entry.snapshot.currentStreak) day streak", systemImage: "flame.fill")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                    Text("\(entry.snapshot.currentStreak)")
                        .font(.headline.weight(.bold))
                }
            }
        default:
            EmptyView()
        }
    }
}
