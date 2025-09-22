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

    @Published var currentSuggestion: Meal?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var recentMealIDs: [UUID] = []

    func generateSuggestion(preferences: UserPreferences) async {
        print("🍽️ [MealService] Starting meal suggestion generation")
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            print("🍽️ [MealService] Calling NetworkService.fetchMealSuggestion")
            var meal = try await network.fetchMealSuggestion(preferences: preferences)
            print("🍽️ [MealService] Received meal from NetworkService: \(meal.title)")

            // Simple filtering by preferences (local safeguard when backend can't filter)
            if meal.prepTime > preferences.maxCookingTime {
                print("🍽️ [MealService] Warning: Meal prep time (\(meal.prepTime)) exceeds max cooking time (\(preferences.maxCookingTime))")
                // In a real implementation, we'd fetch again with different params.
                // For now, accept and rely on backend once wired.
            }
            if let requiredDifficulty = preferences.difficultyPreference, meal.difficulty != requiredDifficulty {
                print("🍽️ [MealService] Warning: Meal difficulty (\(meal.difficulty)) doesn't match preference (\(requiredDifficulty))")
                // Same note as above.
            }
            if !preferences.cuisinePreferences.contains(meal.cuisine) {
                print("🍽️ [MealService] Warning: Meal cuisine (\(meal.cuisine)) not in preferences (\(preferences.cuisinePreferences))")
                // Same note as above.
            }
            if !preferences.dietaryRestrictions.isEmpty {
                // Treat restrictions as desired diet tags (inclusive OR)
                if meal.dietTags.isEmpty || Set(meal.dietTags).isDisjoint(with: preferences.dietaryRestrictions) {
                    print("🍽️ [MealService] Warning: Meal diet tags (\(meal.dietTags)) don't match restrictions (\(preferences.dietaryRestrictions))")
                    // Same note as above.
                }
            }

            // Simple repeat-avoidance: if duplicate of recent, keep but note.
            if recentMealIDs.contains(meal.id) {
                print("🍽️ [MealService] Warning: Meal \(meal.id) was recently shown")
                // With stub data, duplicates are expected.
            }
            recentMealIDs.append(meal.id)
            if recentMealIDs.count > 10 { recentMealIDs.removeFirst() }

            print("🍽️ [MealService] Prefetching image for meal")
            await ImageService.shared.prefetch(url: meal.imageURL)
            currentSuggestion = meal
            print("🍽️ [MealService] Successfully set current suggestion")
        } catch {
            print("🍽️ [MealService] Error generating suggestion: \(error)")
            if let networkError = error as? NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}
