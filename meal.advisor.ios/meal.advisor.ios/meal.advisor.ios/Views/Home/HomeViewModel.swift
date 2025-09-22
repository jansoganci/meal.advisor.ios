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

    private let mealService = MealService()
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }

    func getNewSuggestion() {
        print("🍽️ [HomeViewModel] Get New Suggestion button pressed")
        errorToast = nil
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
            } else if let meal = self.meal {
                print("🍽️ [HomeViewModel] Successfully got meal: \(meal.title)")
                appState.stopLoading()
            } else {
                print("🍽️ [HomeViewModel] No meal received, no error message")
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
