import Foundation
import WidgetKit

// 👱‍♀️ ponytail: one file, two static methods. That's the entire shared container strategy.

/// Reads and writes SharedDataSnapshot JSON to the App Group container.
public enum SharedDataStore {
    
    private static let appGroupID = "group.com.shriyansh1.Atlas"
    private static let fileName = "widget_snapshot.json"
    
    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(fileName)
    }
    
    /// Write snapshot to shared container. Called from main app.
    public static func save(_ snapshot: SharedDataSnapshot) {
        guard let url = fileURL else {
            print("⚠️ SharedDataStore: App Group container not available")
            return
        }
        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: url, options: .atomic)
        } catch {
            print("⚠️ SharedDataStore: Failed to save snapshot: \(error.localizedDescription)")
        }
    }
    
    /// Load snapshot from shared container. Returns defaults if missing (offline-safe).
    public static func load() -> SharedDataSnapshot {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return SharedDataSnapshot()
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SharedDataSnapshot.self, from: data)
        } catch {
            print("⚠️ SharedDataStore: Failed to load snapshot: \(error.localizedDescription)")
            return SharedDataSnapshot()
        }
    }
    
    /// Convenience: save and immediately tell WidgetKit to reload.
    public static func saveAndReload(_ snapshot: SharedDataSnapshot) {
        save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
