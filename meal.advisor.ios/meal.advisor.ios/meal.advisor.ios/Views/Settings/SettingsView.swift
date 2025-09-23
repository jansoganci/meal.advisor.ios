//
//  SettingsView.swift
//  meal.advisor.ios
//
//  Scaffolding: Settings screen placeholder
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @StateObject private var prefsService = UserPreferencesService.shared
    
    init() {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(appState: AppState.shared))
    }

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "preferences")) {
                    SettingsRow.navigation(
                        title: "Serving Size",
                        subtitle: "Number of people",
                        icon: "person.2",
                        iconColor: .blue,
                        destination: AnyView(ServingSizeView())
                    )
                    
                    SettingsRow.navigation(
                        title: String(localized: "dietary_restrictions"),
                        subtitle: "Dietary preferences",
                        icon: "leaf",
                        iconColor: .green,
                        destination: AnyView(DietaryRestrictionsView())
                    )
                    
                    SettingsRow.navigation(
                        title: String(localized: "cooking_time_available"),
                        subtitle: "Maximum prep time",
                        icon: "clock",
                        iconColor: .orange,
                        destination: AnyView(CookingTimeView())
                    )
                    
                    SettingsRow.navigation(
                        title: String(localized: "cuisine_preferences"),
                        subtitle: "Favorite cuisines",
                        icon: "globe",
                        iconColor: .purple,
                        destination: AnyView(CuisinePreferencesView())
                    )
                }

                Section("Notifications") {
                    NotificationToggle(
                        isEnabled: $viewModel.notificationsEnabled,
                        onToggle: {
                            viewModel.toggleNotifications()
                        }
                    )
                    
                    PrivacyToggle(isEnabled: $viewModel.analyticsEnabled)
                }

                Section(String(localized: "account")) {
                    SettingsRow.info(
                        title: "Premium Status",
                        value: viewModel.isPremium ? "Premium ✅" : "Free",
                        subtitle: viewModel.isPremium ? "Active subscription" : "Upgrade available",
                        icon: "crown.fill",
                        iconColor: .yellow
                    )
                    
                    SettingsRow.action(
                        title: viewModel.isPremium ? "Disable Premium (Test)" : "Enable Premium (Test)",
                        icon: "gear",
                        iconColor: .blue,
                        action: viewModel.togglePremium
                    )
                    
                    SettingsRow.action(
                        title: "Sign in with Apple",
                        icon: "person.circle",
                        iconColor: .primary
                    ) {
                        // TODO: Implement Sign in with Apple
                    }
                    
                    SettingsRow.action(
                        title: "Premium Subscription",
                        icon: "creditcard",
                        iconColor: .green
                    ) {
                        viewModel.showPremiumUpgrade()
                    }
                }

                Section("Data") {
                    SettingsRow.action(
                        title: "Reset Preferences",
                        subtitle: "Restore default settings",
                        icon: "arrow.clockwise",
                        iconColor: .orange
                    ) {
                        viewModel.resetPreferences()
                    }
                    
                    SettingsRow.action(
                        title: "Clear Ratings",
                        subtitle: "Remove all meal ratings",
                        icon: "trash",
                        iconColor: .red
                    ) {
                        viewModel.clearRatings()
                    }
                }

                Section(String(localized: "about")) {
                    SettingsRow.action(
                        title: "Privacy Policy",
                        icon: "hand.raised",
                        iconColor: .blue
                    ) {
                        // TODO: Open privacy policy
                    }
                    
                    SettingsRow.action(
                        title: "Terms of Service",
                        icon: "doc.text",
                        iconColor: .secondary
                    ) {
                        // TODO: Open terms of service
                    }
                }
            }
            .navigationTitle(String(localized: "settings"))
        }
        .alert("Premium Required", isPresented: $viewModel.showingPremiumAlert) {
            Button("Upgrade") {
                // TODO: Show paywall
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Premium features require a subscription. Upgrade to unlock unlimited favorites and advanced features!")
        }
        .alert("Sign Out", isPresented: $viewModel.showingSignOutAlert) {
            Button("Sign Out", role: .destructive) {
                viewModel.confirmSignOut()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to sign out? Your preferences will be saved locally.")
        }
    }
}

#Preview {
    SettingsView()
}
