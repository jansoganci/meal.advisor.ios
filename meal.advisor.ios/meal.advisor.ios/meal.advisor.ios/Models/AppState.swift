//
//  AppState.swift
//  meal.advisor.ios
//
//  Global application state management for loading and error handling.
//

import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
}
