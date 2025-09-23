//
//  HomeViewModel.swift
//  meal.advisor.ios
//
//  Handles suggestion loading state and interactions for Home.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var meal: Meal?
    @Published var errorToast: String?
    @Published var isLoading: Bool = false
    @Published var isFallback: Bool = false

    let mealService = MealService()
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }

    func getNewSuggestion() {
        print("🍽️ [HomeViewModel] Get New Suggestion button pressed")
        print("🤖 [HomeViewModel] Using AI-first meal generation with database fallback")
        errorToast = nil
        isLoading = true
        isFallback = false
        appState.startLoading()

        Task {
            let prefs = UserPreferencesService.shared.preferences
            print("🍽️ [HomeViewModel] User preferences: \(prefs)")
            await mealService.generateSuggestion(preferences: prefs)
            self.meal = mealService.currentSuggestion
            
            if let message = mealService.errorMessage {
                print("🍽️ [HomeViewModel] Error from MealService: \(message)")
                appState.setError(message)
                self.errorToast = message
                isLoading = false
            } else if let meal = self.meal {
                print("🍽️ [HomeViewModel] Successfully got meal: \(meal.title)")
                print("🤖 [HomeViewModel] Check NetworkService logs above for AI vs fallback status")
                // Check if this was a fallback meal based on error message content
                if let errorMsg = mealService.errorMessage, errorMsg.contains("fallback") {
                    isFallback = true
                    print("🔄 [HomeViewModel] Detected fallback meal from error message")
                } else {
                    isFallback = false
                    print("🤖 [HomeViewModel] AI-generated meal (no fallback detected)")
                }
                isLoading = false
                appState.stopLoading()
            } else {
                print("🍽️ [HomeViewModel] No meal received, no error message")
                isLoading = false
                appState.stopLoading()
            }
        }
    }
    
    func retry() {
        print("🍽️ [HomeViewModel] Retry button pressed")
        appState.clearError()
        getNewSuggestion()
    }
}
