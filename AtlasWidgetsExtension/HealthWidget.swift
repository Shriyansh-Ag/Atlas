import SwiftUI
import WidgetKit

// MARK: - Health Widget

struct HealthWidget: Widget {
    let kind = "AtlasHealthWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HealthTimelineProvider()) { entry in
            HealthWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Health Snapshot")
        .description("Your key health metrics at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline

struct HealthEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedDataSnapshot
}

struct HealthTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HealthEntry {
        HealthEntry(date: .now, snapshot: SharedDataSnapshot())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> Void) {
        completion(HealthEntry(date: .now, snapshot: SharedDataStore.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HealthEntry>) -> Void) {
        let entry = HealthEntry(date: .now, snapshot: SharedDataStore.load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Views

struct HealthWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: HealthEntry
    
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
        VStack(spacing: 6) {
            Image(systemName: "figure.walk")
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text("\(entry.snapshot.steps)")
                .font(.title2.weight(.bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            
            Text("steps")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var mediumView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "heart.text.square")
                    .foregroundStyle(.red)
                Text("Health Snapshot")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                healthMetric(icon: "figure.walk", title: "Steps", value: "\(entry.snapshot.steps)", color: .blue)
                healthMetric(icon: "bed.double.fill", title: "Sleep", value: "\(entry.snapshot.sleepScore)", color: .indigo)
                healthMetric(icon: "heart.fill", title: "HR", value: "\(entry.snapshot.restingHeartRate) bpm", color: .red)
                healthMetric(icon: "drop.fill", title: "Water", value: String(format: "%.1fL", entry.snapshot.waterIntake), color: .cyan)
            }
        }
        .padding(4)
    }
    
    private func healthMetric(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
                .frame(width: 12)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
