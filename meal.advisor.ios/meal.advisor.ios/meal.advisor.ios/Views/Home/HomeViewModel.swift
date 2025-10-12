//
//  HomeViewModel.swift
//  meal.advisor.ios
//
//  Handles suggestion loading state and interactions for Home.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    // 🎯 STATE: Keep minimal ViewModel state, delegate most to services
    @Published var showQuotaLimitPaywall: Bool = false

    // 🔧 FIX: MealService injected from parent view for proper SwiftUI observation
    let mealService: MealService
    let usageTrackingService = UsageTrackingService.shared
    private let appState: AppState
    
    init(appState: AppState, mealService: MealService) {
        self.appState = appState
        self.mealService = mealService
    }

    func getNewSuggestion() {
        print("🍽️ [HomeViewModel] Get New Suggestion button pressed")
        print("🤖 [HomeViewModel] Using AI-first meal generation with database fallback")
        showQuotaLimitPaywall = false
        appState.startLoading()

        Task {
            let prefs = UserPreferencesService.shared.preferences
            print("🍽️ [HomeViewModel] User preferences: \(prefs)")
            await mealService.generateSuggestion(preferences: prefs)
            
            // 🎯 STATE: Check service state for results
            if mealService.state.isQuotaExceeded {
                print("🍽️ [HomeViewModel] 💎 Quota exceeded - showing paywall")
                showQuotaLimitPaywall = true
                appState.stopLoading()
                return
            }
            
            if let message = mealService.state.errorMessage {
                print("🍽️ [HomeViewModel] Error from MealService: \(message)")
                appState.setError(message)
            } else if let meal = mealService.state.currentSuggestion {
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
