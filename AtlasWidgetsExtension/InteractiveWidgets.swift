import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Interactive Water Widget

struct WaterWidget: Widget {
    let kind = "AtlasWaterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Water Tracker")
        .description("Log water with a single tap.")
        .supportedFamilies([.systemSmall])
    }
}

struct WaterEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataSnapshot
}

struct WaterTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: .now, snapshot: SharedDataSnapshot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> Void) {
        completion(WaterEntry(date: .now, snapshot: SharedDataStore.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void) {
        let entry = WaterEntry(date: .now, snapshot: SharedDataStore.load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Interactive Intent

/// App Intent that adds 250ml of water directly from the widget.
struct LogWaterWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Water"
    static var description = IntentDescription("Add 250ml of water.")
    
    func perform() async throws -> some IntentResult {
        var snapshot = SharedDataStore.load()
        snapshot.waterIntake += 0.25 // 250ml = 0.25L
        snapshot.lastUpdated = Date()
        SharedDataStore.saveAndReload(snapshot)
        return .result()
    }
}

// MARK: - View

struct WaterWidgetView: View {
    let entry: WaterEntry
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                WidgetProgressRing(
                    progress: entry.snapshot.waterProgress,
                    color: .cyan,
                    size: 56,
                    lineWidth: 7
                )
                VStack(spacing: 0) {
                    Text(String(format: "%.1f", entry.snapshot.waterIntake))
                        .font(.caption.weight(.bold))
                    Text("/ \(String(format: "%.0f", entry.snapshot.waterTarget))L")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
            }
            
            Button(intent: LogWaterWidgetIntent()) {
                HStack(spacing: 3) {
                    Image(systemName: "plus")
                        .font(.caption2.weight(.bold))
                    Text("250ml")
                        .font(.caption2.weight(.semibold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.cyan.opacity(0.2))
                .foregroundStyle(.cyan)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Quick Actions Widget (Medium)

struct QuickActionsWidget: Widget {
    let kind = "AtlasQuickActionsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickActionsTimelineProvider()) { entry in
            QuickActionsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quick Actions")
        .description("Log water and meals with one tap.")
        .supportedFamilies([.systemMedium])
    }
}

struct QuickActionsEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataSnapshot
}

struct QuickActionsTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickActionsEntry {
        QuickActionsEntry(date: .now, snapshot: SharedDataSnapshot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickActionsEntry) -> Void) {
        completion(QuickActionsEntry(date: .now, snapshot: SharedDataStore.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionsEntry>) -> Void) {
        let entry = QuickActionsEntry(date: .now, snapshot: SharedDataStore.load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct QuickActionsWidgetView: View {
    let entry: QuickActionsEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Water section
            VStack(spacing: 6) {
                WidgetProgressRing(progress: entry.snapshot.waterProgress, color: .cyan, size: 50, lineWidth: 6)
                Button(intent: LogWaterWidgetIntent()) {
                    Label("+250ml", systemImage: "drop.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.cyan)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Nutrition summary
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Int(entry.snapshot.caloriesRemaining)) kcal left")
                    .font(.subheadline.weight(.bold))
                    .minimumScaleFactor(0.7)
                WidgetMacroBar(label: "Protein", current: entry.snapshot.proteinConsumed, target: entry.snapshot.proteinTarget, color: .blue)
                WidgetStreakDots(streak: entry.snapshot.currentStreak)
            }
        }
        .padding(4)
    }
}
