import SwiftUI
import SwiftData

public struct HealthSettingsView: View {
    public init() {}
    public var body: some View {
        HealthKitAuthorizationView()
    }
}

public struct GoalSettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Milestones") {
                        SettingsToggle(title: "Milestone Celebrations", icon: "party.popper", isOn: $prefs.current.milestoneCelebrations)
                    }
                    
                    SettingsSection(title: "Streaks") {
                        SettingsToggle(title: "Strict Streak Rules", icon: "flame", isOn: $prefs.current.strictStreakRules)
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Goals")
    }
}

public struct NutritionSettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Defaults") {
                        HStack {
                            Text("Default Meal")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Picker("Default Meal", selection: $prefs.current.defaultMeal) {
                                Text("Breakfast").tag("Breakfast")
                                Text("Lunch").tag("Lunch")
                                Text("Dinner").tag("Dinner")
                                Text("Snack").tag("Snack")
                            }
                        }
                        .padding()
                    }
                    
                    SettingsSection(title: "Search Preferences") {
                        SettingsToggle(title: "Search Barcode First", icon: "barcode.viewfinder", isOn: $prefs.current.searchBarcodeFirst)
                        SettingsToggle(title: "Prioritize High Protein", icon: "star", isOn: $prefs.current.prioritizeHighProteinRecipes)
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Nutrition")
    }
}

public struct WorkoutSettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Workout Defaults") {
                        HStack {
                            Text("Rest Timer (s)")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Picker("Rest Timer", selection: $prefs.current.defaultRestTimerSeconds) {
                                Text("30s").tag(30)
                                Text("60s").tag(60)
                                Text("90s").tag(90)
                                Text("120s").tag(120)
                            }
                        }
                        .padding()
                        
                        HStack {
                            Text("Warm-up Sets")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Picker("Warm-up Sets", selection: $prefs.current.defaultWarmupSets) {
                                Text("0").tag(0)
                                Text("1").tag(1)
                                Text("2").tag(2)
                                Text("3").tag(3)
                            }
                        }
                        .padding()
                    }
                    
                    SettingsSection(title: "Features") {
                        SettingsToggle(title: "Auto Progression", icon: "arrow.up.right.circle", isOn: $prefs.current.autoProgression)
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Workout")
    }
}

public struct AppearanceSettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Theme") {
                        HStack {
                            Text("App Theme")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Picker("Theme", selection: $prefs.current.theme) {
                                Text("System").tag(AppTheme.system)
                                Text("Light").tag(AppTheme.light)
                                Text("Dark").tag(AppTheme.dark)
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                    }
                    
                    SettingsSection(title: "Effects") {
                        SettingsToggle(title: "UI Animations", icon: "sparkles", isOn: $prefs.current.useAnimations)
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Appearance")
    }
}

public struct UnitSettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Measurements") {
                        unitPicker(title: "Weight", selection: $prefs.current.weightUnit, options: WeightUnit.allCases)
                        Divider().padding(.leading, 16)
                        unitPicker(title: "Distance", selection: $prefs.current.distanceUnit, options: DistanceUnit.allCases)
                        Divider().padding(.leading, 16)
                        unitPicker(title: "Energy", selection: $prefs.current.energyUnit, options: EnergyUnit.allCases)
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Units")
    }
    
    @ViewBuilder
    private func unitPicker<T: Hashable & RawRepresentable>(title: String, selection: Binding<T>, options: [T]) -> some View where T.RawValue == String {
        HStack {
            Text(title)
                .atlasFont(.body)
                .foregroundColor(Color.Atlas.textPrimary)
            Spacer()
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.rawValue.uppercased()).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 150)
        }
        .padding()
    }
}

public struct PrivacySettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Data Collection") {
                        SettingsToggle(title: "Share Analytics", icon: "chart.bar", isOn: $prefs.current.shareDataWithDeveloper)
                    }
                    
                    SettingsSection(title: "Policies") {
                        HStack {
                            Text("Privacy Policy")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(Color.Atlas.primary)
                        }
                        .padding()
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Privacy")
    }
}

public struct DataManagementView: View {
    @State private var showingFactoryResetConfirmation = false
    
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    DangerZoneCard(
                        title: "Clear App Cache",
                        description: "Frees up local storage without deleting health or workout data.",
                        actionTitle: "Clear Cache"
                    ) {
                        PrivacyManager.shared.clearAllCaches()
                    }
                    
                    DangerZoneCard(
                        title: "Reset Search History",
                        description: "Clears your food and exercise search history.",
                        actionTitle: "Clear History"
                    ) {
                        // TODO: Implement
                    }
                    
                    DangerZoneCard(
                        title: "Factory Reset",
                        description: "Permanently deletes all data and resets the app to its original state. This cannot be undone.",
                        actionTitle: "Erase All Data"
                    ) {
                        showingFactoryResetConfirmation = true
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Data Management")
        .alert("Erase All Data?", isPresented: $showingFactoryResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Erase Everything", role: .destructive) {
                // TODO: Wipe SwiftData completely
            }
        } message: {
            Text("This will permanently delete all workouts, meals, progress photos, and settings.")
        }
    }
}

public struct ImportExportView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Export Options") {
                        Button(action: {
                            // TODO: Trigger ExportManager
                        }) {
                            HStack {
                                Text("Export as CSV")
                                    .atlasFont(.body)
                                    .foregroundColor(Color.Atlas.textPrimary)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Color.Atlas.primary)
                            }
                            .padding()
                        }
                    }
                    
                    SettingsSection(title: "Import Options") {
                        Button(action: {
                            // TODO: Trigger ImportManager
                        }) {
                            HStack {
                                Text("Import from CSV")
                                    .atlasFont(.body)
                                    .foregroundColor(Color.Atlas.textPrimary)
                                Spacer()
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(Color.Atlas.primary)
                            }
                            .padding()
                        }
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Import / Export")
    }
}

public struct AccessibilitySettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Accessibility") {
                        SettingsToggle(title: "Haptic Feedback", icon: "hand.tap", isOn: $prefs.current.enableHaptics)
                        SettingsToggle(title: "Large Text Mode", icon: "textformat.size", isOn: $prefs.current.useLargeText)
                        SettingsToggle(title: "High Contrast", icon: "circle.lefthalf.filled", isOn: $prefs.current.highContrast)
                        SettingsToggle(title: "Reduce Motion", icon: "wind", isOn: $prefs.current.reduceMotion)
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Accessibility")
    }
}

public struct SupportSettingsView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Help & Feedback") {
                        HStack {
                            Text("FAQ")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Image(systemName: "questionmark.circle")
                        }
                        .padding()
                        
                        HStack {
                            Text("Contact Support")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Image(systemName: "envelope")
                        }
                        .padding()
                        
                        HStack {
                            Text("Rate Atlas")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Image(systemName: "star")
                        }
                        .padding()
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Support")
    }
}

public struct AboutSettingsView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            VStack(spacing: Spacing.large) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundColor(Color.Atlas.primary)
                
                Text("Atlas")
                    .atlasFont(.largeTitle)
                    .foregroundColor(Color.Atlas.textPrimary)
                
                Text("Version 1.0.0 (42)")
                    .atlasFont(.subheadline)
                    .foregroundColor(Color.Atlas.textSecondary)
            }
        }
        .navigationTitle("About Atlas")
    }
}

public struct DeveloperSettingsView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Diagnostic Tools") {
                        HStack {
                            Text("Database Inspector")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Image(systemName: "cylinder.split.1x2")
                        }
                        .padding()
                        
                        HStack {
                            Text("Performance Diagnostics")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Image(systemName: "speedometer")
                        }
                        .padding()
                    }
                    
                    DangerZoneCard(
                        title: "Generate Mock Data",
                        description: "Fills the database with 30 days of mock workouts and nutrition for testing.",
                        actionTitle: "Generate"
                    ) {
                        // TODO: Implement mock data generator
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Developer Tools")
    }
}

public struct WidgetSettingsView: View {
    @AppStorage("liveActivityEnabled") private var liveActivityEnabled = true
    @AppStorage("dynamicIslandEnabled") private var dynamicIslandEnabled = true
    @AppStorage("widgetRefreshMinutes") private var widgetRefreshMinutes = 30
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.large) {
                    SettingsSection(title: "Live Activity") {
                        SettingsToggle(title: "Workout Live Activity", icon: "figure.run", isOn: $liveActivityEnabled)
                        SettingsToggle(title: "Dynamic Island", icon: "apps.iphone", isOn: $dynamicIslandEnabled)
                    }
                    
                    SettingsSection(title: "Widget Refresh") {
                        HStack {
                            Text("Refresh Interval")
                                .atlasFont(.body)
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Picker("Refresh", selection: $widgetRefreshMinutes) {
                                Text("15 min").tag(15)
                                Text("30 min").tag(30)
                                Text("60 min").tag(60)
                            }
                            .pickerStyle(.menu)
                        }
                        .padding()
                    }
                    
                    SettingsSection(title: "Siri & Shortcuts") {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(Color.Atlas.primary)
                                .frame(width: 24)
                            Text("Siri Integration is always active. Try saying:")
                                .atlasFont(.caption)
                                .foregroundColor(Color.Atlas.textSecondary)
                        }
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\"Show today's calories in Atlas\"")
                                .atlasFont(.caption)
                                .foregroundColor(Color.Atlas.textPrimary)
                                .italic()
                            Text("\"Log water in Atlas\"")
                                .atlasFont(.caption)
                                .foregroundColor(Color.Atlas.textPrimary)
                                .italic()
                            Text("\"Start today's workout in Atlas\"")
                                .atlasFont(.caption)
                                .foregroundColor(Color.Atlas.textPrimary)
                                .italic()
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .padding(Spacing.medium)
            }
        }
        .navigationTitle("Widgets & Siri")
    }
}


struct PlaceholderSettingsView: View {
    let title: String
    let icon: String
    
    var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            EmptyState(
                title: "Coming Soon",
                description: "\(title) settings will be available in a future update.",
                icon: icon,
                actionTitle: "Go Back",
                action: {}
            )
        }
        .navigationTitle(title)
    }
}
