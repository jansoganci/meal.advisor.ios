//
//  FavoritesService.swift
//  meal.advisor.ios
//
//  Local favorites management with UserDefaults persistence
//

import Foundation
import SwiftUI

@MainActor
final class FavoritesService: ObservableObject {
    static let shared = FavoritesService()
    
    @Published var favorites: [Meal] = []
    @Published var isLoading = false
    
    private let defaults = UserDefaults.standard
    private let favoritesKey = "saved_meal_ids_v1"
    private let mealService = MealService()
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    /// Check if a meal is currently favorited
    func isFavorite(_ meal: Meal) -> Bool {
        return favorites.contains { $0.id == meal.id }
    }
    
    /// Add meal to favorites (premium-gated)
    func addFavorite(_ meal: Meal) async throws {
        // Premium gating - throw error if not premium
        guard AppState.shared.isPremium else {
            print("🍽️ [FavoritesService] Favorites require premium subscription")
            throw FavoritesError.premiumRequired
        }
        
        guard !isFavorite(meal) else { return }
        
        print("🍽️ [FavoritesService] Adding meal to favorites: \(meal.title)")
        
        // Add to local array
        favorites.append(meal)
        
        // Save to UserDefaults
        saveFavoriteIds()
        
        print("🍽️ [FavoritesService] Meal added successfully. Total favorites: \(favorites.count)")
    }
    
    /// Remove meal from favorites
    func removeFavorite(_ meal: Meal) async throws {
        guard let index = favorites.firstIndex(where: { $0.id == meal.id }) else { return }
        
        print("🍽️ [FavoritesService] Removing meal from favorites: \(meal.title)")
        
        // Remove from local array
        favorites.remove(at: index)
        
        // Save to UserDefaults
        saveFavoriteIds()
        
        print("🍽️ [FavoritesService] Meal removed successfully. Total favorites: \(favorites.count)")
    }
    
    /// Toggle favorite status of a meal
    func toggleFavorite(_ meal: Meal) async throws {
        if isFavorite(meal) {
            try await removeFavorite(meal)
        } else {
            try await addFavorite(meal)
        }
    }
    
    /// Clear all favorites (for testing/reset)
    func clearAllFavorites() {
        print("🍽️ [FavoritesService] Clearing all favorites")
        favorites.removeAll()
        saveFavoriteIds()
    }
    
    // MARK: - Private Methods
    
    /// Load favorites from UserDefaults on app launch
    private func loadFavorites() {
        print("🍽️ [FavoritesService] Loading favorites from UserDefaults")
        
        guard let savedIds = defaults.array(forKey: favoritesKey) as? [String] else {
            print("🍽️ [FavoritesService] No saved favorites found")
            return
        }
        
        print("🍽️ [FavoritesService] Found \(savedIds.count) saved favorite IDs")
        
        // Convert string IDs back to UUIDs and load meals
        Task {
            await loadMealsFromIds(savedIds)
        }
    }
    
    /// Load full meal objects from saved IDs
    private func loadMealsFromIds(_ savedIds: [String]) async {
        isLoading = true
        defer { isLoading = false }
        
        var loadedMeals: [Meal] = []
        
        for idString in savedIds {
            guard let uuid = UUID(uuidString: idString) else { continue }
            
            // For now, we'll need to fetch meals individually
            // TODO: When we have a batch fetch API, use that instead
            if let meal = await findMealById(uuid) {
                loadedMeals.append(meal)
            }
        }
        
        favorites = loadedMeals
        print("🍽️ [FavoritesService] Loaded \(loadedMeals.count) favorite meals")
    }
    
    /// Save current favorite IDs to UserDefaults
    private func saveFavoriteIds() {
        let ids = favorites.map { $0.id.uuidString }
        defaults.set(ids, forKey: favoritesKey)
        print("🍽️ [FavoritesService] Saved \(ids.count) favorite IDs to UserDefaults")
    }
    
    /// Find a meal by ID (temporary implementation)
    /// TODO: Replace with proper API call when available
    private func findMealById(_ id: UUID) async -> Meal? {
        // For now, return nil since we don't have a "fetch by ID" API yet
        // This will be implemented when we add the backend endpoint
        print("🍽️ [FavoritesService] TODO: Implement findMealById API call")
        return nil
    }
}

// MARK: - Error Types

enum FavoritesError: LocalizedError {
    case premiumRequired
    case mealNotFound
    case storageError
    
    var errorDescription: String? {
        switch self {
        case .premiumRequired:
            return "Favorites require a Premium subscription"
        case .mealNotFound:
            return "Meal not found"
        case .storageError:
            return "Failed to save favorite"
        }
    }
}
