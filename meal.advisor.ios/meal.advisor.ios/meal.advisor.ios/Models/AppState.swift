//
//  AppState.swift
//  meal.advisor.ios
//
//  Global application state management for loading and error handling.
//

import Foundation

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState() // Singleton instance
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPremium = false
    @Published var isAuthenticated = false
    
    private let purchaseService = PurchaseService.shared
    private let authService = AuthService.shared
    private var subscriptionObserver: Task<Void, Never>?
    private var authObserver: Task<Void, Never>?
    
    private init() {
        // Start observing subscription status
        subscriptionObserver = Task {
            await observeSubscriptionStatus()
        }
        
        // Start observing auth status
        authObserver = Task {
            await observeAuthStatus()
        }
    }
    
    deinit {
        subscriptionObserver?.cancel()
        authObserver?.cancel()
    }
    
    // MARK: - Subscription Monitoring
    
    /// Observe subscription status changes
    private func observeSubscriptionStatus() async {
        // Initial status check
        await updatePremiumStatus()
        
        // Continue monitoring for changes
        for await _ in NotificationCenter.default.notifications(named: NSNotification.Name("SubscriptionStatusChanged")) {
            await updatePremiumStatus()
        }
    }
    
    /// Update premium status based on PurchaseService
    private func updatePremiumStatus() async {
        let wasPremium = isPremium
        isPremium = purchaseService.subscriptionStatus.isPremium
        
        if wasPremium != isPremium {
            print("🍽️ [AppState] Premium status changed to: \(isPremium)")
        }
    }
    
    /// Manually refresh subscription status
    func refreshSubscriptionStatus() async {
        await purchaseService.updateSubscriptionStatus()
        await updatePremiumStatus()
    }
    
    // MARK: - Authentication Monitoring
    
    /// Observe authentication status changes
    private func observeAuthStatus() async {
        // Initial status check
        isAuthenticated = authService.isAuthenticated
        
        // Continue monitoring for changes
        for await _ in NotificationCenter.default.notifications(named: NSNotification.Name("AuthStatusChanged")) {
            print("🔔 [AppState] Received AuthStatusChanged notification")
            isAuthenticated = authService.isAuthenticated
            print("🍽️ [AppState] Auth status updated to: \(isAuthenticated)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Set loading state to true and clear any existing error
    func startLoading() {
        isLoading = true
        errorMessage = nil
    }
    
    /// Set loading state to false
    func stopLoading() {
        isLoading = false
    }
    
    /// Set error message and stop loading
    func setError(_ message: String) {
        isLoading = false
        errorMessage = message
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Reset all state
    func reset() {
        isLoading = false
        errorMessage = nil
    }
    
    /// Toggle premium status (for testing purposes)
    func togglePremium() {
        isPremium.toggle()
        print("🍽️ [AppState] Premium status toggled to: \(isPremium)")
    }
}
