import SwiftUI

public struct SettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.large) {
                        
                        SettingsSection(title: "Account") {
                            SettingsNavigationRow(title: "Profile", icon: "person.crop.circle", destination: ProfileSettingsView())
                            SettingsNavigationRow(title: "Goals", icon: "target", destination: GoalSettingsView())
                        }
                        
                        SettingsSection(title: "Health & Fitness") {
                            SettingsNavigationRow(title: "Health Integration", icon: "heart.text.square", destination: HealthSettingsView())
                            SettingsNavigationRow(title: "Nutrition", icon: "fork.knife", destination: NutritionSettingsView())
                            SettingsNavigationRow(title: "Workout", icon: "dumbbell", destination: WorkoutSettingsView())
                        }
                        
                        SettingsSection(title: "Preferences") {
                            SettingsNavigationRow(title: "Appearance", icon: "paintbrush", destination: AppearanceSettingsView())
                            SettingsNavigationRow(title: "Units", icon: "ruler", destination: UnitSettingsView())
                            SettingsNavigationRow(title: "Notifications", icon: "bell", destination: NotificationSettingsView())
                            SettingsNavigationRow(title: "Atlas Intelligence", icon: "brain", destination: AISettingsView())
                            SettingsNavigationRow(title: "Widgets & Siri", icon: "widget.small", destination: WidgetSettingsView())
                        }
                        
                        SettingsSection(title: "System") {
                            SettingsNavigationRow(title: "Privacy", icon: "hand.raised", destination: PrivacySettingsView())
                            SettingsNavigationRow(title: "Data Management", icon: "externaldrive", destination: DataManagementView())
                            SettingsNavigationRow(title: "Import / Export", icon: "arrow.up.arrow.down", destination: ImportExportView())
                            SettingsNavigationRow(title: "Accessibility", icon: "accessibility", destination: AccessibilitySettingsView())
                        }
                        
                        SettingsSection(title: "About") {
                            SettingsNavigationRow(title: "Support & Feedback", icon: "questionmark.circle", destination: SupportSettingsView())
                            SettingsNavigationRow(title: "About Atlas", icon: "info.circle", destination: AboutSettingsView())
                            
                            #if DEBUG
                            SettingsNavigationRow(title: "Developer Options", icon: "hammer", destination: DeveloperSettingsView())
                            #endif
                        }
                        
                        Text("Version 1.0.0 (Build 42)\nMade with ❤️ by Shriyansh")
                            .atlasFont(.caption2)
                            .foregroundColor(Color.Atlas.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, Spacing.medium)
                            .padding(.bottom, Spacing.xxLarge)
                    }
                    .padding(Spacing.medium)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
