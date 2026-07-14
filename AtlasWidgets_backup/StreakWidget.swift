import SwiftUI
import WidgetKit

// MARK: - Streak Widget

struct StreakWidget: Widget {
    let kind = "AtlasStreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Your daily training streak.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Timeline

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
}

struct StreakTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, streak: 7)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let s = SharedDataStore.load()
        completion(StreakEntry(date: .now, streak: s.currentStreak))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let s = SharedDataStore.load()
        let entry = StreakEntry(date: .now, streak: s.currentStreak)
        // Refresh at midnight when streak could change
        let tomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }
}

// MARK: - View

struct StreakWidgetView: View {
    let entry: StreakEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.largeTitle)
                .foregroundStyle(
                    entry.streak > 0
                        ? LinearGradient(colors: [.orange, .red], startPoint: .bottom, endPoint: .top)
                        : LinearGradient(colors: [.gray], startPoint: .bottom, endPoint: .top)
                )
            
            Text("\(entry.streak)")
                .font(.title.weight(.bold))
            
            Text(entry.streak == 1 ? "day" : "days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
