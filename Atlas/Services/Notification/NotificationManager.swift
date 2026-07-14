import Foundation
import UserNotifications
import SwiftData
import Combine

@MainActor
public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var isAuthorized = false
    
    private init() {}
    
    public func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            self.isAuthorized = granted
            if granted {
                // Initial schedule on first grant
                scheduleDailyReminders(preferences: NotificationPreferences())
            }
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    public func scheduleDailyReminders(preferences: NotificationPreferences) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // Reset all
        
        guard isAuthorized else { return }
        
        // 1. Morning Daily Briefing (8:00 AM)
        if preferences.goalUpdates {
            scheduleNotification(id: "daily_briefing", title: "Good Morning", body: "Check your goal progress and plan your day.", hour: 8, minute: 0)
        }
        
        // 2. Workout Reminder (17:00 PM) - Will be cancelled by background task if already done
        if preferences.workoutReminders {
            scheduleNotification(id: "workout_reminder", title: "Time to Train", body: "Don't break your streak! Get your workout in.", hour: 17, minute: 0)
        }
        
        // 3. Protein/Meals Reminder (20:00 PM) - Will be cancelled if protein goal met
        if preferences.proteinReminders {
            scheduleNotification(id: "protein_reminder", title: "Protein Check", body: "Log your dinner to hit your protein goal.", hour: 20, minute: 0)
        }
        
        // 4. Sleep Reminder (Based on Quiet Hours)
        if preferences.sleepReminders {
            var sleepHour = preferences.quietHoursStartHour - 1 // Remind 1 hr before quiet time
            if sleepHour < 0 { sleepHour = 23 }
            scheduleNotification(id: "sleep_reminder", title: "Wind Down", body: "Time to start winding down for recovery.", hour: sleepHour, minute: 0)
        }
    }
    
    private func scheduleNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification \(id): \(error)")
            }
        }
    }
    
    // Called by background tasks when an objective is met (e.g. Protein > Target)
    public func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
