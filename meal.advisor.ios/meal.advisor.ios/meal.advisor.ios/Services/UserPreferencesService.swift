//
//  UserPreferencesService.swift
//  meal.advisor.ios
//
//  Persists and publishes user preferences via UserDefaults.
//

import Foundation

final class UserPreferencesService: ObservableObject {
    static let shared = UserPreferencesService()

    @Published var preferences: UserPreferences {
        didSet { save() }
    }

    private let defaults = UserDefaults.standard
    private let key = "user_preferences_v1"

    private init() {
        if let data = defaults.data(forKey: key),
           let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            preferences = prefs
        } else {
            preferences = .default
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: key)
        }
    }
    
    // MARK: - Meal Rating Methods
    
    /// Get rating for a specific meal
    func getRating(for mealId: UUID) -> MealRating? {
        return preferences.mealRatings[mealId]
    }
    
    /// Set rating for a specific meal
    func setRating(_ rating: MealRating, for mealId: UUID) {
        preferences.mealRatings[mealId] = rating
        print("🍽️ [UserPreferencesService] Set rating \(rating.rawValue) for meal \(mealId)")
    }
    
    /// Remove rating for a specific meal
    func removeRating(for mealId: UUID) {
        preferences.mealRatings.removeValue(forKey: mealId)
        print("🍽️ [UserPreferencesService] Removed rating for meal \(mealId)")
    }
    
    /// Get all liked meal IDs
    func getLikedMealIds() -> [UUID] {
        return preferences.mealRatings.compactMap { mealId, rating in
            rating == .liked ? mealId : nil
        }
    }
    
    /// Get all disliked meal IDs
    func getDislikedMealIds() -> [UUID] {
        return preferences.mealRatings.compactMap { mealId, rating in
            rating == .disliked ? mealId : nil
        }
    }
    
    /// Get rating statistics
    func getRatingStats() -> (liked: Int, disliked: Int, total: Int) {
        let liked = preferences.mealRatings.values.filter { $0 == .liked }.count
        let disliked = preferences.mealRatings.values.filter { $0 == .disliked }.count
        let total = preferences.mealRatings.count
        return (liked: liked, disliked: disliked, total: total)
    }
}

