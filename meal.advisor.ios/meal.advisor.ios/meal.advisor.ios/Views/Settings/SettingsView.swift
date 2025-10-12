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
    @StateObject private var appState = AppState.shared
    @StateObject private var authService = AuthService.shared
    @State private var showPaywall = false
    @State private var showSignInPrompt = false
    @State private var showEmailSignIn = false
    @Environment(\.openURL) private var openURL
    
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
                    
                    if appState.isAuthenticated {
                        SettingsRow.info(
                            title: "Signed In",
                            value: authService.currentUser?.email ?? "Apple ID",
                            subtitle: "Account active",
                            icon: "person.circle.fill",
                            iconColor: .green
                        )
                        
                        SettingsRow.action(
                            title: "Sign Out",
                            icon: "arrow.right.square",
                            iconColor: .red
                        ) {
                            viewModel.signOut()
                        }
                    } else {
                        // Apple Sign-In Button
                        VStack(spacing: 8) {
                            AppleSignInButton(
                                onSuccess: {
                                    print("🍎 [Settings] Apple Sign-In successful")
                                },
                                onError: { error in
                                    print("🍎 [Settings] Apple Sign-In error: \(error)")
                                }
                            )
                            .frame(height: 44)
                        }
                        .padding(.horizontal, 16)
                        
                        SettingsRow.action(
                            title: "Sign in with Google",
                            icon: "g.circle.fill",
                            iconColor: .blue
                        ) {
                            Task {
                                do {
                                    try await authService.signInWithGoogle()
                                } catch {
                                    print("Google sign-in failed: \(error)")
                                }
                            }
                        }
                        
                        SettingsRow.action(
                            title: "Sign in with Email",
                            icon: "envelope",
                            iconColor: .blue
                        ) {
                            showEmailSignIn = true
                        }
                    }
                    
                    SettingsRow.action(
                        title: "Premium Subscription",
                        icon: "creditcard",
                        iconColor: .green
                    ) {
                        showPaywall = true
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
                        // Open Privacy Policy in Safari
                        if let url = URL(string: "https://jansoganci.github.io/meal.advisor.ios/privacy-policy.html") {
                            openURL(url)
                        }
                    }
                    
                    SettingsRow.action(
                        title: "Terms of Service",
                        icon: "doc.text",
                        iconColor: .secondary
                    ) {
                        // Open Terms of Service in Safari
                        if let url = URL(string: "https://jansoganci.github.io/meal.advisor.ios/terms.html") {
                            openURL(url)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        Text("Photos provided by")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Link("Unsplash", destination: URL(string: "https://unsplash.com/?utm_source=meal_advisor&utm_medium=referral")!)
                            .font(.subheadline)
                            .foregroundColor(.accentGreen)
                    }
                } header: {
                    Text("Attribution")
                }
            }
            .navigationTitle(String(localized: "settings"))
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(source: .settings)
        }
        .sheet(isPresented: $showSignInPrompt) {
            SignInPromptView(context: .premiumFeature)
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView()
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
