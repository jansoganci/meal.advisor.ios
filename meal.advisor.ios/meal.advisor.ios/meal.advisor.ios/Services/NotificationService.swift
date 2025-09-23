//
//  NotificationService.swift
//  meal.advisor.ios
//
//  Push notification service for meal reminders
//

import Foundation
import UserNotifications
import SwiftUI

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized: Bool = false
    @Published var mealRemindersEnabled: Bool = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let mealRemindersKey = "meal_reminders_enabled"
    private let notificationPermissionKey = "notification_permission_granted"
    
    // Notification identifiers
    private let lunchReminderId = "lunch_reminder"
    private let dinnerReminderId = "dinner_reminder"
    private let breakfastReminderId = "breakfast_reminder"
    
    private init() {
        loadSettings()
        checkNotificationPermission()
    }
    
    // MARK: - Permission Management
    
    /// Request notification permission from user
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            
            if granted {
                defaults.set(true, forKey: notificationPermissionKey)
                print("🔔 [NotificationService] Notification permission granted")
                
                // Schedule default meal reminders if user enables them
                if mealRemindersEnabled {
                    await scheduleDefaultMealReminders()
                }
            } else {
                defaults.set(false, forKey: notificationPermissionKey)
                mealRemindersEnabled = false
                print("🔔 [NotificationService] Notification permission denied")
            }
            
            return granted
        } catch {
            print("🔔 [NotificationService] Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Check current notification permission status
    private func checkNotificationPermission() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Meal Reminders
    
    /// Enable or disable meal reminders
    func setMealRemindersEnabled(_ enabled: Bool) {
        mealRemindersEnabled = enabled
        defaults.set(enabled, forKey: mealRemindersKey)
        
        if enabled && isAuthorized {
            Task {
                await scheduleDefaultMealReminders()
            }
        } else {
            cancelAllMealReminders()
        }
        
        print("🔔 [NotificationService] Meal reminders \(enabled ? "enabled" : "disabled")")
    }
    
    /// Schedule default meal reminder notifications
    func scheduleDefaultMealReminders() async {
        guard isAuthorized && mealRemindersEnabled else { return }
        
        // Cancel existing reminders first
        cancelAllMealReminders()
        
        // Schedule breakfast reminder (8:00 AM daily)
        await scheduleMealReminder(
            id: breakfastReminderId,
            title: "Good morning! 🌅",
            body: "Ready for breakfast? Tap to get a suggestion!",
            hour: 8,
            minute: 0
        )
        
        // Schedule lunch reminder (12:00 PM daily)
        await scheduleMealReminder(
            id: lunchReminderId,
            title: "Lunch time! 🍽️",
            body: "What sounds good for lunch today?",
            hour: 12,
            minute: 0
        )
        
        // Schedule dinner reminder (6:00 PM daily)
        await scheduleMealReminder(
            id: dinnerReminderId,
            title: "Dinner time! 🌆",
            body: "Time to decide what's for dinner tonight!",
            hour: 18,
            minute: 0
        )
        
        print("🔔 [NotificationService] Scheduled default meal reminders")
    }
    
    /// Schedule a specific meal reminder
    private func scheduleMealReminder(
        id: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Add custom data for deep linking
        content.userInfo = [
            "type": "meal_reminder",
            "meal_time": id,
            "deep_link": "mealadvisor://suggestion"
        ]
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            print("🔔 [NotificationService] Scheduled reminder: \(id) at \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("🔔 [NotificationService] Failed to schedule reminder \(id): \(error)")
        }
    }
    
    /// Cancel all meal reminder notifications
    func cancelAllMealReminders() {
        let identifiers = [breakfastReminderId, lunchReminderId, dinnerReminderId]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
        
        print("🔔 [NotificationService] Cancelled all meal reminders")
    }
    
    /// Cancel a specific meal reminder
    func cancelMealReminder(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
        
        print("🔔 [NotificationService] Cancelled reminder: \(id)")
    }
    
    // MARK: - Custom Notifications
    
    /// Send an immediate notification (for testing or special events)
    func sendImmediateNotification(title: String, body: String, delay: TimeInterval = 1.0) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("🔔 [NotificationService] Sent immediate notification: \(title)")
        } catch {
            print("🔔 [NotificationService] Failed to send immediate notification: \(error)")
        }
    }
    
    /// Schedule a custom meal reminder at specific time
    func scheduleCustomMealReminder(
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) async {
        let id = "custom_\(UUID().uuidString)"
        await scheduleMealReminder(
            id: id,
            title: title,
            body: body,
            hour: hour,
            minute: minute
        )
    }
    
    // MARK: - Notification Handling
    
    /// Handle notification when app is in foreground
    func handleNotificationInForeground(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "meal_reminder" {
            // Handle meal reminder notification
            print("🔔 [NotificationService] Received meal reminder in foreground")
            
            // You could trigger a suggestion generation here if desired
            // or show an in-app notification/banner
        }
    }
    
    /// Handle notification when app is in background
    func handleNotificationInBackground(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "meal_reminder" {
            print("🔔 [NotificationService] Received meal reminder in background")
            
            // Handle deep linking if needed
            if let deepLink = userInfo["deep_link"] as? String {
                print("🔔 [NotificationService] Deep link: \(deepLink)")
            }
        }
    }
    
    // MARK: - Settings Management
    
    /// Load notification settings from UserDefaults
    private func loadSettings() {
        mealRemindersEnabled = defaults.bool(forKey: mealRemindersKey)
    }
    
    /// Get pending notification requests (for debugging)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    /// Get delivered notifications (for debugging)
    func getDeliveredNotifications() async -> [UNNotification] {
        return await notificationCenter.deliveredNotifications()
    }
    
    /// Clear all delivered notifications
    func clearAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        print("🔔 [NotificationService] Cleared all delivered notifications")
    }
    
    // MARK: - Notification Statistics
    
    /// Get notification settings summary
    func getNotificationSummary() -> (isAuthorized: Bool, mealRemindersEnabled: Bool, pendingCount: Int) {
        // Note: This is a simplified version. For real count, you'd need async/await
        return (isAuthorized: isAuthorized, mealRemindersEnabled: mealRemindersEnabled, pendingCount: 0)
    }
}

// MARK: - Notification Categories

extension NotificationService {
    /// Setup notification categories for interactive notifications
    func setupNotificationCategories() {
        // Meal reminder category with action buttons
        let viewAction = UNNotificationAction(
            identifier: "VIEW_SUGGESTION",
            title: "Get Suggestion",
            options: [.foreground]
        )
        
        let laterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Later",
            options: []
        )
        
        let mealReminderCategory = UNNotificationCategory(
            identifier: "MEAL_REMINDER",
            actions: [viewAction, laterAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([mealReminderCategory])
        print("🔔 [NotificationService] Setup notification categories")
    }
}
