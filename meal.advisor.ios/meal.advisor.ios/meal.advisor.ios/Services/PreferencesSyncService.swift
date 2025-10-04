//
//  PreferencesSyncService.swift
//  meal.advisor.ios
//
//  Sync user preferences and meal ratings between local storage and Supabase
//

import Foundation
#if canImport(Supabase)
import Supabase
#endif

@MainActor
final class PreferencesSyncService {
    static let shared = PreferencesSyncService()
    
    private let supabaseClient = SupabaseClientManager.shared
    private let preferencesService = UserPreferencesService.shared
    private let authService = AuthService.shared
    
    private init() {}
    
    // MARK: - Upload to Supabase
    
    /// Upload local preferences to Supabase
    func uploadPreferences() async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("⚠️ [PreferencesSync] Supabase not configured, skipping upload")
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            print("⚠️ [PreferencesSync] No active session, cannot upload preferences")
            return
        }
        
        let localPrefs = preferencesService.preferences
        print("📤 [PreferencesSync] Uploading user preferences")
        
        do {
            // Check if preferences already exist
            let existing: [UserPreferencesRow] = try await client
                .from("user_preferences")
                .select()
                .eq("user_id", value: session.user.id.uuidString)
                .execute()
                .value
            
            let prefsRow = UserPreferencesRow(
                id: existing.first?.id ?? UUID(),
                user_id: session.user.id,
                dietary_restrictions: Array(localPrefs.dietaryRestrictions.map { $0.rawValue }),
                cuisine_preferences: Array(localPrefs.cuisinePreferences.map { $0.rawValue }),
                max_cooking_time: localPrefs.maxCookingTime,
                difficulty_preference: localPrefs.difficultyPreference?.rawValue,
                excluded_ingredients: Array(localPrefs.excludedIngredients),
                meal_ratings: nil, // Meal ratings synced separately
                serving_size: localPrefs.servingSize,
                created_at: Date(),
                updated_at: Date()
            )
            
            if existing.isEmpty {
                // Insert new preferences
                try await client
                    .from("user_preferences")
                    .insert(prefsRow)
                    .execute()
                
                print("✅ [PreferencesSync] Inserted new preferences")
            } else {
                // Update existing preferences
                try await client
                    .from("user_preferences")
                    .update(prefsRow)
                    .eq("user_id", value: session.user.id.uuidString)
                    .execute()
                
                print("✅ [PreferencesSync] Updated existing preferences")
            }
            
            // Upload meal ratings separately
            try await uploadMealRatings(userId: session.user.id)
            
            print("✅ [PreferencesSync] Upload completed")
        } catch {
            print("❌ [PreferencesSync] Failed to upload preferences: \(error)")
            throw error
        }
    }
    
    // MARK: - Download from Supabase
    
    /// Download preferences from Supabase
    func downloadPreferences() async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("⚠️ [PreferencesSync] Supabase not configured, skipping download")
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            print("⚠️ [PreferencesSync] No active session, cannot download preferences")
            return
        }
        
        print("📥 [PreferencesSync] Downloading preferences from Supabase")
        
        do {
            // Fetch user preferences
            let rows: [UserPreferencesRow] = try await client
                .from("user_preferences")
                .select()
                .eq("user_id", value: session.user.id.uuidString)
                .execute()
                .value
            
            if let prefsRow = rows.first {
                // Update local preferences
                var updatedPrefs = preferencesService.preferences
                updatedPrefs.dietaryRestrictions = Set(prefsRow.dietary_restrictions?.compactMap { Meal.DietType(rawValue: $0) } ?? [])
                updatedPrefs.cuisinePreferences = Set(prefsRow.cuisine_preferences?.compactMap { Meal.Cuisine(rawValue: $0) } ?? [])
                updatedPrefs.maxCookingTime = prefsRow.max_cooking_time ?? 60
                updatedPrefs.difficultyPreference = prefsRow.difficulty_preference.flatMap { Meal.Difficulty(rawValue: $0) }
                updatedPrefs.excludedIngredients = Set(prefsRow.excluded_ingredients ?? [])
                updatedPrefs.servingSize = prefsRow.serving_size ?? 2
                
                preferencesService.preferences = updatedPrefs
                
                print("✅ [PreferencesSync] Downloaded and applied preferences")
            } else {
                print("ℹ️ [PreferencesSync] No preferences found in cloud, using local")
            }
            
            // Download meal ratings
            try await downloadMealRatings(userId: session.user.id)
            
            print("✅ [PreferencesSync] Download completed")
        } catch {
            print("❌ [PreferencesSync] Failed to download preferences: \(error)")
            throw error
        }
    }
    
    // MARK: - Meal Ratings Sync
    
    /// Upload meal ratings to Supabase
    private func uploadMealRatings(userId: UUID) async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else { return }
        
        let ratings = preferencesService.preferences.mealRatings
        print("📤 [PreferencesSync] Uploading \(ratings.count) meal ratings")
        
        for (mealId, rating) in ratings {
            // Skip none ratings
            guard rating != .none else { continue }
            
            do {
                // Check if rating already exists
                let existing: [MealRatingRow] = try await client
                    .from("meal_ratings")
                    .select()
                    .eq("user_id", value: userId.uuidString)
                    .eq("meal_id", value: mealId.uuidString)
                    .execute()
                    .value
                
                let ratingRow = MealRatingRow(
                    id: existing.first?.id ?? UUID(),
                    user_id: userId,
                    meal_id: mealId,
                    rating: rating.rawValue,
                    created_at: Date(),
                    updated_at: Date()
                )
                
                if existing.isEmpty {
                    // Insert new rating
                    try await client
                        .from("meal_ratings")
                        .insert(ratingRow)
                        .execute()
                } else {
                    // Update existing rating
                    try await client
                        .from("meal_ratings")
                        .update(ratingRow)
                        .eq("user_id", value: userId.uuidString)
                        .eq("meal_id", value: mealId.uuidString)
                        .execute()
                }
                
                print("✅ [PreferencesSync] Uploaded rating for meal: \(mealId)")
            } catch {
                print("❌ [PreferencesSync] Failed to upload rating: \(error)")
            }
        }
    }
    
    /// Download meal ratings from Supabase
    private func downloadMealRatings(userId: UUID) async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else { return }
        
        print("📥 [PreferencesSync] Downloading meal ratings")
        
        do {
            let ratings: [MealRatingRow] = try await client
                .from("meal_ratings")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            print("📥 [PreferencesSync] Found \(ratings.count) ratings in cloud")
            
            // Merge with local ratings
            var currentPrefs = preferencesService.preferences
            for ratingRow in ratings {
                if let mealRating = MealRating(rawValue: ratingRow.rating) {
                    currentPrefs.mealRatings[ratingRow.meal_id] = mealRating
                }
            }
            
            preferencesService.preferences = currentPrefs
            
            print("✅ [PreferencesSync] Downloaded and merged \(ratings.count) ratings")
        } catch {
            print("❌ [PreferencesSync] Failed to download ratings: \(error)")
            throw error
        }
    }
    
    // MARK: - Sync All
    
    /// Perform full bidirectional sync with timestamp-based conflict resolution
    func syncAll() async throws {
        guard authService.isAuthenticated else {
            print("ℹ️ [PreferencesSync] Not authenticated, skipping sync")
            return
        }
        
        print("🔄 [PreferencesSync] Starting full sync with conflict resolution")
        
        // Conflict resolution strategy:
        // 1. Compare local and cloud timestamps
        // 2. Keep the most recent version
        // 3. For meal ratings, merge with most recent wins per meal
        
        do {
            try await resolvePreferencesConflicts()
        } catch {
            print("⚠️ [PreferencesSync] Conflict resolution failed, using default sync: \(error)")
            // Fallback to simple sync
            try await downloadPreferences()
            try await uploadPreferences()
        }
        
        print("✅ [PreferencesSync] Full sync completed")
    }
    
    // MARK: - Conflict Resolution
    
    /// Resolve conflicts between local and cloud preferences
    /// Uses timestamp-based strategy: most recent version wins
    private func resolvePreferencesConflicts() async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            throw SupabaseClientError.notConfigured
        }
        
        guard let session = await supabaseClient.currentSession else {
            throw SupabaseClientError.sessionNotFound
        }
        
        print("🔄 [PreferencesSync] Resolving preferences conflicts")
        
        // Fetch cloud preferences
        let cloudPrefs: [UserPreferencesRow] = try await client
            .from("user_preferences")
            .select()
            .eq("user_id", value: session.user.id.uuidString)
            .execute()
            .value
        
        if let cloudPref = cloudPrefs.first {
            let cloudTimestamp = cloudPref.updated_at
            let localTimestamp = getLocalPreferencesTimestamp()
            
            if cloudTimestamp > localTimestamp {
                // Cloud is newer, download
                print("☁️ [PreferencesSync] Cloud preferences are newer, downloading")
                try await downloadPreferences()
            } else if localTimestamp > cloudTimestamp {
                // Local is newer, upload
                print("📱 [PreferencesSync] Local preferences are newer, uploading")
                try await uploadPreferences()
            } else {
                // Same timestamp, already synced
                print("✅ [PreferencesSync] Preferences already in sync")
            }
        } else {
            // No cloud preferences, upload local
            print("📤 [PreferencesSync] No cloud preferences, uploading local")
            try await uploadPreferences()
        }
        
        // Merge meal ratings (keep most recent per meal)
        try await mergeMealRatings()
        
        print("✅ [PreferencesSync] Conflict resolution completed")
    }
    
    /// Merge meal ratings from local and cloud, keeping most recent per meal
    private func mergeMealRatings() async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            return
        }
        
        print("🔄 [PreferencesSync] Merging meal ratings")
        
        // Get cloud ratings
        let cloudRatings: [MealRatingRow] = try await client
            .from("meal_ratings")
            .select()
            .eq("user_id", value: session.user.id.uuidString)
            .execute()
            .value
        
        var currentPrefs = preferencesService.preferences
        var merged = currentPrefs.mealRatings
        
        // Merge with cloud ratings (cloud wins for conflicts)
        for cloudRating in cloudRatings {
            if let mealRating = MealRating(rawValue: cloudRating.rating) {
                if let localTimestamp = getLocalRatingTimestamp(for: cloudRating.meal_id) {
                    // Compare timestamps
                    if cloudRating.updated_at > localTimestamp {
                        merged[cloudRating.meal_id] = mealRating
                        print("☁️ [PreferencesSync] Using cloud rating for meal: \(cloudRating.meal_id)")
                    }
                } else {
                    // No local rating, use cloud
                    merged[cloudRating.meal_id] = mealRating
                }
            }
        }
        
        currentPrefs.mealRatings = merged
        preferencesService.preferences = currentPrefs
        
        print("✅ [PreferencesSync] Merged \(merged.count) meal ratings")
    }
    
    /// Get timestamp for local preferences
    private func getLocalPreferencesTimestamp() -> Date {
        // For now, return current date as we don't track local timestamps
        // In production, you'd track this in UserDefaults or local storage
        return Date()
    }
    
    /// Get timestamp for a specific local meal rating
    private func getLocalRatingTimestamp(for mealId: UUID) -> Date? {
        // For now, return nil to prefer cloud ratings
        // In production, you'd track timestamps per rating
        return nil
    }
    
}

// MARK: - Data Models

struct UserPreferencesRow: Codable {
    let id: UUID
    let user_id: UUID
    let dietary_restrictions: [String]?
    let cuisine_preferences: [String]?
    let max_cooking_time: Int?
    let difficulty_preference: String?
    let excluded_ingredients: [String]?
    let meal_ratings: [String: Int]?
    let serving_size: Int?
    let created_at: Date
    let updated_at: Date
}

struct MealRatingRow: Codable {
    let id: UUID
    let user_id: UUID
    let meal_id: UUID
    let rating: String  // MealRating rawValue (none, liked, disliked)
    let created_at: Date
    let updated_at: Date
}


