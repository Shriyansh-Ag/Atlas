import Foundation
import SwiftUI
import Combine

/// Central hub for app settings and managers
public class SettingsModule {
    public static let shared = SettingsModule()
    
    public let preferences = PreferencesManager.shared
    public let appearance = AppearanceManager.shared
    public let units = UnitsManager.shared
    
    private init() {}
}

public class PreferencesManager: ObservableObject {
    public static let shared = PreferencesManager()
    
    private let defaults = UserDefaults.standard
    private let preferencesKey = "atlas_app_preferences"
    
    @Published public var current: AppPreferences {
        didSet {
            save()
        }
    }
    
    private init() {
        if let data = defaults.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(AppPreferences.self, from: data) {
            self.current = decoded
        } else {
            self.current = AppPreferences()
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(current) {
            defaults.set(encoded, forKey: preferencesKey)
        }
    }
}

public class AppearanceManager {
    public static let shared = AppearanceManager()
    private init() {}
    
    public func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard PreferencesManager.shared.current.enableHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

public class UnitsManager {
    public static let shared = UnitsManager()
    private init() {}
    
    // Weight conversions
    public func kgToLbs(_ kg: Double) -> Double { kg * 2.20462 }
    public func lbsToKg(_ lbs: Double) -> Double { lbs / 2.20462 }
    
    public func formatWeight(_ kg: Double) -> String {
        let prefs = PreferencesManager.shared.current
        if prefs.weightUnit == .lbs {
            return String(format: "%.1f lbs", kgToLbs(kg))
        }
        return String(format: "%.1f kg", kg)
    }
    
    // Distance conversions
    public func kmToMiles(_ km: Double) -> Double { km * 0.621371 }
    public func milesToKm(_ miles: Double) -> Double { miles / 0.621371 }
    
    // Energy conversions
    public func kcalToKj(_ kcal: Double) -> Double { kcal * 4.184 }
    public func kjToKcal(_ kj: Double) -> Double { kj / 4.184 }
}

public class ExportManager {
    public static let shared = ExportManager()
    private init() {}
    
    public func exportDataAsJSON() async throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("atlas_export_\(Date().timeIntervalSince1970).json")
        let dummyData = "{\"export_version\": 1}".data(using: .utf8)!
        try dummyData.write(to: fileURL)
        return fileURL
    }
    
    public func exportDataAsCSV() async throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("atlas_export_\(Date().timeIntervalSince1970).csv")
        let dummyData = "Date,Workout,Calories\n2026-07-14,Push,500".data(using: .utf8)!
        try dummyData.write(to: fileURL)
        return fileURL
    }
}

public class ImportManager {
    public static let shared = ImportManager()
    private init() {}
    
    public func importData(from url: URL) async throws {
        // Implementation stub
        print("Importing from \(url)")
    }
}

public class BackupManager {
    public static let shared = BackupManager()
    private init() {}
    
    public func backupToCloudKit() async throws {
        // Implementation stub for future CloudKit integration
    }
    
    public func restoreFromCloudKit() async throws {
        // Implementation stub for future CloudKit integration
    }
}

public class FeedbackManager {
    public static let shared = FeedbackManager()
    private init() {}
    
    public func openSupportEmail() {
        if let url = URL(string: "mailto:support@atlas.com") {
            UIApplication.shared.open(url)
        }
    }
}

public class PrivacyManager {
    public static let shared = PrivacyManager()
    private init() {}
    
    public func clearAllCaches() {
        // Clear logic stub
    }
}
