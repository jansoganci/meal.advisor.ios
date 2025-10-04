//
//  AnalyticsService.swift
//  meal.advisor.ios
//
//  Privacy-first analytics and event tracking
//

import Foundation

@MainActor
final class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published var analyticsEnabled = true
    
    private let defaults = UserDefaults.standard
    private let analyticsEnabledKey = "analytics_enabled"
    
    // Session tracking
    private var sessionStartTime: Date?
    private var suggestionCount = 0
    
    private init() {
        loadSettings()
        startSession()
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        analyticsEnabled = defaults.object(forKey: analyticsEnabledKey) as? Bool ?? true
    }
    
    func setAnalyticsEnabled(_ enabled: Bool) {
        analyticsEnabled = enabled
        defaults.set(enabled, forKey: analyticsEnabledKey)
        print("📊 [AnalyticsService] Analytics \(enabled ? "enabled" : "disabled")")
    }
    
    // MARK: - Session Tracking
    
    private func startSession() {
        sessionStartTime = Date()
        print("📊 [AnalyticsService] Session started")
    }
    
    func endSession() {
        guard let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        trackEvent(.sessionEnded, properties: [
            "duration_seconds": duration,
            "suggestions_generated": suggestionCount
        ])
        
        sessionStartTime = nil
        suggestionCount = 0
    }
    
    // MARK: - Event Tracking
    
    enum AnalyticsEvent: String {
        // App Lifecycle
        case appLaunched = "app_launched"
        case sessionEnded = "session_ended"
        
        // Suggestion Events
        case suggestionGenerated = "suggestion_generated"
        case suggestionViewed = "suggestion_viewed"
        case recipeViewed = "recipe_viewed"
        
        // User Actions
        case mealRated = "meal_rated"
        case favoriteSaved = "favorite_saved"
        case favoriteRemoved = "favorite_removed"
        
        // Premium Events
        case paywallViewed = "paywall_viewed"
        case purchaseStarted = "purchase_started"
        case purchaseCompleted = "purchase_completed"
        case purchaseFailed = "purchase_failed"
        case subscriptionRestored = "subscription_restored"
        
        // Auth Events
        case signInPromptShown = "sign_in_prompt_shown"
        case signInCompleted = "sign_in_completed"
        case signInCancelled = "sign_in_cancelled"
        case signOutCompleted = "sign_out_completed"
        
        // Settings Events
        case preferencesChanged = "preferences_changed"
        case notificationsEnabled = "notifications_enabled"
        case notificationsDisabled = "notifications_disabled"
        
        // Engagement
        case deliveryLinkTapped = "delivery_link_tapped"
        case recipeShared = "recipe_shared"
    }
    
    /// Track an analytics event
    func trackEvent(_ event: AnalyticsEvent, properties: [String: Any] = [:]) {
        guard analyticsEnabled else { return }
        
        var eventData: [String: Any] = properties
        eventData["event_name"] = event.rawValue
        eventData["timestamp"] = Date().timeIntervalSince1970
        eventData["device_id"] = AuthService.shared.deviceID
        
        if let userID = AuthService.shared.currentUser?.id {
            eventData["user_id"] = userID
        }
        
        // Add app context
        eventData["is_premium"] = AppState.shared.isPremium
        eventData["is_authenticated"] = AppState.shared.isAuthenticated
        
        // Log event
        print("📊 [AnalyticsService] Event: \(event.rawValue)")
        if !properties.isEmpty {
            print("📊 [AnalyticsService] Properties: \(properties)")
        }
        
        // TODO: Send to Supabase analytics table
        // Task {
        //     try? await supabase
        //         .from("events")
        //         .insert(eventData)
        //         .execute()
        // }
        
        // Store locally for debugging
        storeEventLocally(event, data: eventData)
    }
    
    // MARK: - Convenience Tracking Methods
    
    func trackSuggestionGenerated(mealID: UUID, cuisine: String, prepTime: Int, source: String) {
        suggestionCount += 1
        trackEvent(.suggestionGenerated, properties: [
            "meal_id": mealID.uuidString,
            "cuisine": cuisine,
            "prep_time": prepTime,
            "source": source, // "ai", "database", "offline"
            "suggestion_number": suggestionCount
        ])
    }
    
    func trackMealRated(mealID: UUID, rating: String) {
        trackEvent(.mealRated, properties: [
            "meal_id": mealID.uuidString,
            "rating": rating
        ])
    }
    
    func trackPurchase(productID: String, price: Decimal, success: Bool) {
        let event: AnalyticsEvent = success ? .purchaseCompleted : .purchaseFailed
        trackEvent(event, properties: [
            "product_id": productID,
            "price": NSDecimalNumber(decimal: price).doubleValue
        ])
    }
    
    func trackPaywallView(source: String) {
        trackEvent(.paywallViewed, properties: [
            "source": source // "favorites", "suggestion_limit", "settings"
        ])
    }
    
    func trackSignIn(provider: String, success: Bool) {
        let event: AnalyticsEvent = success ? .signInCompleted : .signInCancelled
        trackEvent(event, properties: [
            "provider": provider
        ])
    }
    
    // MARK: - Local Storage (for debugging)
    
    private func storeEventLocally(_ event: AnalyticsEvent, data: [String: Any]) {
        let eventsKey = "analytics_events_log"
        var events = defaults.array(forKey: eventsKey) as? [[String: Any]] ?? []
        
        events.append(data)
        
        // Keep only last 100 events
        if events.count > 100 {
            events = Array(events.suffix(100))
        }
        
        defaults.set(events, forKey: eventsKey)
    }
    
    func getLocalEvents() -> [[String: Any]] {
        let eventsKey = "analytics_events_log"
        return defaults.array(forKey: eventsKey) as? [[String: Any]] ?? []
    }
    
    func clearLocalEvents() {
        let eventsKey = "analytics_events_log"
        defaults.removeObject(forKey: eventsKey)
        print("📊 [AnalyticsService] Cleared local events")
    }
    
    // MARK: - Statistics
    
    func getSessionStats() -> (duration: TimeInterval, suggestionsGenerated: Int) {
        guard let startTime = sessionStartTime else {
            return (0, suggestionCount)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        return (duration, suggestionCount)
    }
}
