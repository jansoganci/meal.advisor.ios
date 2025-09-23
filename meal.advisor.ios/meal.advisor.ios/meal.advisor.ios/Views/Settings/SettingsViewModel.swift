//
//  SettingsViewModel.swift
//  meal.advisor.ios
//
//  Settings screen state management and actions
//

import Foundation
import SwiftUI
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isPremium: Bool
    @Published var notificationsEnabled: Bool = false
    @Published var analyticsEnabled: Bool = true
    @Published var showingPremiumAlert = false
    @Published var showingSignOutAlert = false
    
    private let appState: AppState
    private let preferencesService = UserPreferencesService.shared
    private let notificationService = NotificationService.shared
    
    init(appState: AppState) {
        self.appState = appState
        self.isPremium = appState.isPremium
        
        // Load notification settings
        loadNotificationSettings()
    }
    
    // MARK: - Premium Actions
    
    func togglePremium() {
        appState.togglePremium()
        isPremium = appState.isPremium
    }
    
    func showPremiumUpgrade() {
        showingPremiumAlert = true
    }
    
    // MARK: - Notification Actions
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
        
        if notificationsEnabled {
            // Request permission and enable meal reminders
            Task {
                let granted = await notificationService.requestNotificationPermission()
                if granted {
                    notificationService.setMealRemindersEnabled(true)
                    print("🔔 [SettingsViewModel] Notifications enabled and meal reminders scheduled")
                } else {
                    // Permission denied, revert toggle
                    notificationsEnabled = false
                    print("🔔 [SettingsViewModel] Notification permission denied")
                }
            }
        } else {
            // Disable meal reminders
            notificationService.setMealRemindersEnabled(false)
            print("🔔 [SettingsViewModel] Notifications disabled")
        }
    }
    
    func requestNotificationPermission() {
        Task {
            let granted = await notificationService.requestNotificationPermission()
            if granted {
                notificationsEnabled = true
                notificationService.setMealRemindersEnabled(true)
            }
        }
    }
    
    // MARK: - Analytics Actions
    
    func toggleAnalytics() {
        analyticsEnabled.toggle()
        // Save to UserDefaults
        UserDefaults.standard.set(analyticsEnabled, forKey: "analytics_enabled")
    }
    
    // MARK: - Sign Out Actions
    
    func signOut() {
        showingSignOutAlert = true
    }
    
    func confirmSignOut() {
        // TODO: Implement actual sign out logic
        print("🍽️ [SettingsViewModel] User signed out")
    }
    
    // MARK: - Reset Actions
    
    func resetPreferences() {
        preferencesService.preferences = .default
        print("🍽️ [SettingsViewModel] Preferences reset to defaults")
    }
    
    func clearRatings() {
        preferencesService.preferences.mealRatings = [:]
        print("🍽️ [SettingsViewModel] All meal ratings cleared")
    }
    
    // MARK: - Private Methods
    
    private func loadNotificationSettings() {
        // Load from NotificationService instead of UserDefaults directly
        notificationsEnabled = notificationService.mealRemindersEnabled
        analyticsEnabled = UserDefaults.standard.object(forKey: "analytics_enabled") as? Bool ?? true
    }
}
