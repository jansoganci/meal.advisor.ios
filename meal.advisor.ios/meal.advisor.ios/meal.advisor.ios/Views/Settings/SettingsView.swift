//
//  SettingsView.swift
//  meal.advisor.ios
//
//  Scaffolding: Settings screen placeholder
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var prefsService = UserPreferencesService.shared
    @StateObject private var appState = AppState.shared

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "preferences")) {
                    NavigationLink("Serving Size") {
                        ServingSizeView()
                    }
                    NavigationLink(String(localized: "dietary_restrictions")) {
                        DietaryRestrictionsView()
                    }
                    NavigationLink(String(localized: "cooking_time_available")) {
                        CookingTimeView()
                    }
                    NavigationLink(String(localized: "cuisine_preferences")) {
                        CuisinePreferencesView()
                    }
                }

                Section(String(localized: "account")) {
                    // Premium Status (for testing)
                    HStack {
                        Text("Premium Status")
                        Spacer()
                        Text(appState.isPremium ? "Premium ✅" : "Free")
                            .foregroundColor(appState.isPremium ? .green : .secondary)
                    }
                    
                    // Premium Toggle (for testing)
                    Button(appState.isPremium ? "Disable Premium (Test)" : "Enable Premium (Test)") {
                        appState.togglePremium()
                    }
                    .foregroundColor(.blue)
                    
                    Text("Sign in with Apple")
                    Text("Premium Subscription")
                }

                Section(String(localized: "about")) {
                    Text("Privacy Policy")
                    Text("Terms of Service")
                }
            }
            .navigationTitle(String(localized: "settings"))
        }
    }
}

#Preview {
    SettingsView()
}
