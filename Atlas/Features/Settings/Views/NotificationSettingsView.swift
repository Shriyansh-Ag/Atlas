import SwiftUI
import SwiftData

public struct NotificationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var prefsList: [NotificationPreferences]
    
    @State private var prefs: NotificationPreferences?
    @State private var isAuthorized: Bool = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                if !isAuthorized {
                    GlassCard {
                        VStack(spacing: Spacing.medium) {
                            Image(systemName: "bell.slash.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            
                            Text("Notifications Disabled")
                                .atlasFont(AtlasTypography.headline())
                                .foregroundColor(Color.Atlas.textPrimary)
                            
                            Text("Atlas needs notification access to send you smart reminders about your goals, workouts, and nutrition.")
                                .atlasFont(AtlasTypography.caption())
                                .foregroundColor(Color.Atlas.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: requestPermissions) {
                                Text("Enable Notifications")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.Atlas.primary)
                                    .cornerRadius(CornerRadius.medium)
                            }
                        }
                    }
                    .padding(Spacing.medium)
                }
                
                if let p = prefs {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Smart Reminders")
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(Color.Atlas.textPrimary)
                            .padding(.horizontal, Spacing.medium)
                        
                        GlassCard {
                            VStack(spacing: Spacing.medium) {
                                Toggle("Daily Briefing", isOn: Binding(
                                    get: { p.goalUpdates },
                                    set: { p.goalUpdates = $0; saveAndReschedule() }
                                ))
                                .tint(Color.Atlas.primary)
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                Toggle("Workout Reminders", isOn: Binding(
                                    get: { p.workoutReminders },
                                    set: { p.workoutReminders = $0; saveAndReschedule() }
                                ))
                                .tint(Color.Atlas.primary)
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                Toggle("Protein & Meal Reminders", isOn: Binding(
                                    get: { p.proteinReminders },
                                    set: { p.proteinReminders = $0; saveAndReschedule() }
                                ))
                                .tint(Color.Atlas.primary)
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                Toggle("Sleep / Wind Down", isOn: Binding(
                                    get: { p.sleepReminders },
                                    set: { p.sleepReminders = $0; saveAndReschedule() }
                                ))
                                .tint(Color.Atlas.primary)
                            }
                        }
                        .padding(.horizontal, Spacing.medium)
                        
                        Text("Reminders are automatically cancelled if you've already completed the activity.")
                            .atlasFont(AtlasTypography.caption())
                            .foregroundColor(Color.Atlas.textSecondary)
                            .padding(.horizontal, Spacing.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Quiet Hours")
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(Color.Atlas.textPrimary)
                            .padding(.horizontal, Spacing.medium)
                        
                        GlassCard {
                            VStack(spacing: Spacing.medium) {
                                HStack {
                                    Text("Start Time (Hour)")
                                    Spacer()
                                    Stepper("\(p.quietHoursStartHour):00", value: Binding(
                                        get: { p.quietHoursStartHour },
                                        set: { p.quietHoursStartHour = $0; saveAndReschedule() }
                                    ), in: 0...23)
                                }
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                HStack {
                                    Text("End Time (Hour)")
                                    Spacer()
                                    Stepper("\(p.quietHoursEndHour):00", value: Binding(
                                        get: { p.quietHoursEndHour },
                                        set: { p.quietHoursEndHour = $0; saveAndReschedule() }
                                    ), in: 0...23)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.medium)
                    }
                }
            }
            .padding(.vertical, Spacing.large)
        }
        .background(Color.Atlas.background.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPrefs()
            checkPermissions()
        }
    }
    
    private func loadPrefs() {
        if let existing = prefsList.first {
            self.prefs = existing
        } else {
            let newPrefs = NotificationPreferences()
            modelContext.insert(newPrefs)
            try? modelContext.save()
            self.prefs = newPrefs
        }
    }
    
    private func checkPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    private func requestPermissions() {
        Task {
            await NotificationManager.shared.requestAuthorization()
            checkPermissions()
        }
    }
    
    private func saveAndReschedule() {
        try? modelContext.save()
        if let p = prefs {
            NotificationManager.shared.scheduleDailyReminders(preferences: p)
        }
    }
}
