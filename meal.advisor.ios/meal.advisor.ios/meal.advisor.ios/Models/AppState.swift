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
    @Published var isPremium = false // TODO: Connect to actual subscription status
    
    private init() {} // Private initializer for singleton
    
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
