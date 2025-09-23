//
//  OfflineService.swift
//  meal.advisor.ios
//
//  Local meal storage and offline capabilities
//

import Foundation
import Network

@MainActor
final class OfflineService: ObservableObject {
    static let shared = OfflineService()
    
    @Published var isOffline: Bool = false
    @Published var hasOfflineMeals: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let defaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let offlineMealsKey = "offline_meals_v1"
    private let lastSyncKey = "last_sync_date"
    
    // Cached meals for offline use
    private var cachedMeals: [Meal] = []
    
    private init() {
        setupNetworkMonitoring()
        loadCachedMeals()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOffline = path.status != .satisfied
                print("🌐 [OfflineService] Network status: \(path.status == .satisfied ? "Online" : "Offline")")
            }
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - Meal Caching
    
    /// Cache a meal for offline use
    func cacheMeal(_ meal: Meal) {
        // Remove existing meal with same ID if present
        cachedMeals.removeAll { $0.id == meal.id }
        
        // Add new meal
        cachedMeals.append(meal)
        
        // Limit cache size (keep last 50 meals)
        if cachedMeals.count > 50 {
            cachedMeals = Array(cachedMeals.suffix(50))
        }
        
        saveCachedMeals()
        updateHasOfflineMeals()
        
        print("💾 [OfflineService] Cached meal: \(meal.title)")
    }
    
    /// Cache multiple meals at once
    func cacheMeals(_ meals: [Meal]) {
        for meal in meals {
            cacheMeal(meal)
        }
    }
    
    /// Get a random cached meal for offline suggestions
    func getRandomOfflineMeal() -> Meal? {
        guard !cachedMeals.isEmpty else { return nil }
        
        let randomIndex = Int.random(in: 0..<cachedMeals.count)
        let meal = cachedMeals[randomIndex]
        
        print("💾 [OfflineService] Retrieved offline meal: \(meal.title)")
        return meal
    }
    
    /// Get cached meals filtered by preferences
    func getOfflineMeals(matching preferences: UserPreferences) -> [Meal] {
        return cachedMeals.filter { meal in
            // Filter by cooking time
            guard meal.prepTime <= preferences.maxCookingTime else { return false }
            
            // Filter by difficulty if specified
            if let difficultyPreference = preferences.difficultyPreference {
                guard meal.difficulty == difficultyPreference else { return false }
            }
            
            // Filter by cuisine preferences
            guard preferences.cuisinePreferences.contains(meal.cuisine) else { return false }
            
            // Filter by dietary restrictions
            if !preferences.dietaryRestrictions.isEmpty {
                let mealDietTags = Set(meal.dietTags)
                let userRestrictions = preferences.dietaryRestrictions
                
                // Check if meal has any of the user's dietary restrictions
                guard !mealDietTags.isDisjoint(with: userRestrictions) else { return false }
            }
            
            // Filter by excluded ingredients
            if !preferences.excludedIngredients.isEmpty {
                let mealIngredients = meal.ingredients.map { $0.name.lowercased() }
                let excludedIngredients = preferences.excludedIngredients.map { $0.lowercased() }
                
                guard !mealIngredients.contains(where: { ingredient in
                    excludedIngredients.contains { excluded in
                        ingredient.contains(excluded) || excluded.contains(ingredient)
                    }
                }) else { return false }
            }
            
            return true
        }
    }
    
    /// Get a random offline meal matching preferences
    func getRandomOfflineMeal(matching preferences: UserPreferences) -> Meal? {
        let matchingMeals = getOfflineMeals(matching: preferences)
        return matchingMeals.randomElement()
    }
    
    /// Clear all cached meals
    func clearCache() {
        cachedMeals.removeAll()
        saveCachedMeals()
        updateHasOfflineMeals()
        print("💾 [OfflineService] Cleared all cached meals")
    }
    
    /// Get cache statistics
    func getCacheStats() -> (count: Int, lastSync: Date?) {
        let lastSync = defaults.object(forKey: lastSyncKey) as? Date
        return (count: cachedMeals.count, lastSync: lastSync)
    }
    
    // MARK: - Persistence
    
    private func loadCachedMeals() {
        guard let data = defaults.data(forKey: offlineMealsKey) else {
            updateHasOfflineMeals()
            return
        }
        
        do {
            cachedMeals = try JSONDecoder().decode([Meal].self, from: data)
            updateHasOfflineMeals()
            print("💾 [OfflineService] Loaded \(cachedMeals.count) cached meals")
        } catch {
            print("💾 [OfflineService] Failed to load cached meals: \(error)")
            cachedMeals = []
            updateHasOfflineMeals()
        }
    }
    
    private func saveCachedMeals() {
        do {
            let data = try JSONEncoder().encode(cachedMeals)
            defaults.set(data, forKey: offlineMealsKey)
            defaults.set(Date(), forKey: lastSyncKey)
        } catch {
            print("💾 [OfflineService] Failed to save cached meals: \(error)")
        }
    }
    
    private func updateHasOfflineMeals() {
        hasOfflineMeals = !cachedMeals.isEmpty
    }
    
    // MARK: - Offline Status
    
    /// Check if we can provide offline suggestions
    func canProvideOfflineSuggestions(for preferences: UserPreferences) -> Bool {
        return !getOfflineMeals(matching: preferences).isEmpty
    }
    
    /// Get offline status message
    func getOfflineStatusMessage() -> String {
        if isOffline {
            if hasOfflineMeals {
                return "Offline mode - showing cached suggestions"
            } else {
                return "No internet connection and no cached meals available"
            }
        } else {
            return "Online - fetching fresh suggestions"
        }
    }
}
