//
//  MealService.swift
//  meal.advisor.ios
//
//  Core business logic placeholder
//

import Foundation

@MainActor
final class MealService: ObservableObject {
    private let network = NetworkService()
    private let preferencesService = UserPreferencesService.shared
    private let offlineService = OfflineService.shared

    @Published var currentSuggestion: Meal?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOfflineMode = false
    private var recentMealIDs: [UUID] = []

    func generateSuggestion(preferences: UserPreferences) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Get disliked meal IDs to avoid suggesting them again
            let dislikedMealIds = preferencesService.getDislikedMealIds()
            let allExcludedMealIds = recentMealIDs + dislikedMealIds
            
            let meal = try await network.fetchMealSuggestion(preferences: preferences, recentMealIds: allExcludedMealIds)
            
            // Update offline mode status
            isOfflineMode = offlineService.isOffline

            // Local preference validation (safeguard when backend filtering is insufficient)
            if meal.prepTime > preferences.maxCookingTime {
                print("🍽️ [MealService] Warning: Meal prep time (\(meal.prepTime)) exceeds max cooking time (\(preferences.maxCookingTime))")
            }
            if let requiredDifficulty = preferences.difficultyPreference, meal.difficulty != requiredDifficulty {
                print("🍽️ [MealService] Warning: Meal difficulty (\(meal.difficulty)) doesn't match preference (\(requiredDifficulty))")
            }
            if !preferences.cuisinePreferences.contains(meal.cuisine) {
                print("🍽️ [MealService] Warning: Meal cuisine (\(meal.cuisine)) not in preferences (\(preferences.cuisinePreferences))")
            }
            if !preferences.dietaryRestrictions.isEmpty {
                // Treat restrictions as desired diet tags (inclusive OR)
                if meal.dietTags.isEmpty || Set(meal.dietTags).isDisjoint(with: preferences.dietaryRestrictions) {
                    print("🍽️ [MealService] Warning: Meal diet tags (\(meal.dietTags)) don't match restrictions (\(preferences.dietaryRestrictions))")
                }
            }

            // Simple repeat-avoidance check
            if recentMealIDs.contains(meal.id) {
                print("🍽️ [MealService] Warning: Meal \(meal.id) was recently shown")
            }
            recentMealIDs.append(meal.id)
            if recentMealIDs.count > 10 { recentMealIDs.removeFirst() }

            // Prefetch meal image for better UX
            await ImageService.shared.prefetch(url: meal.imageURL)
            currentSuggestion = meal
        } catch {
            // Update offline mode status
            isOfflineMode = offlineService.isOffline
            
            if let networkError = error as? NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Meal Rating Methods
    
    /// Rate a meal (like/dislike/none)
    func rateMeal(_ meal: Meal, rating: MealRating) {
        preferencesService.setRating(rating, for: meal.id)
        
        // If the meal was disliked, remove it from recent meals to avoid suggesting it again
        if rating == .disliked && recentMealIDs.contains(meal.id) {
            recentMealIDs.removeAll { $0 == meal.id }
            print("🍽️ [MealService] Removed disliked meal \(meal.id) from recent suggestions")
        }
        
        print("🍽️ [MealService] Rated meal '\(meal.title)' as \(rating.rawValue)")
    }
    
    /// Get rating for a specific meal
    func getRating(for meal: Meal) -> MealRating? {
        return preferencesService.getRating(for: meal.id)
    }
    
    /// Get rating statistics
    func getRatingStats() -> (liked: Int, disliked: Int, total: Int) {
        return preferencesService.getRatingStats()
    }
    
    // MARK: - Offline Methods
    
    /// Get offline status
    func getOfflineStatus() -> (isOffline: Bool, hasOfflineContent: Bool) {
        return (isOffline: offlineService.isOffline, hasOfflineContent: offlineService.hasOfflineMeals)
    }
    
    /// Get offline status message
    func getOfflineStatusMessage() -> String {
        return offlineService.getOfflineStatusMessage()
    }
    
    /// Check if offline suggestions are available for current preferences
    func canProvideOfflineSuggestions() -> Bool {
        let preferences = preferencesService.preferences
        return offlineService.canProvideOfflineSuggestions(for: preferences)
    }
    
    /// Get offline cache statistics
    func getOfflineCacheStats() -> (count: Int, lastSync: Date?) {
        return offlineService.getCacheStats()
    }
    
    /// Clear offline cache
    func clearOfflineCache() {
        offlineService.clearCache()
    }
}
