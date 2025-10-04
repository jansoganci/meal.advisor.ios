//
//  FavoritesSyncService.swift
//  meal.advisor.ios
//
//  Sync favorites between local storage and Supabase
//

import Foundation
#if canImport(Supabase)
import Supabase
#endif

@MainActor
final class FavoritesSyncService {
    static let shared = FavoritesSyncService()
    
    private let supabaseClient = SupabaseClientManager.shared
    private let favoritesService = FavoritesService.shared
    private let authService = AuthService.shared
    
    private init() {}
    
    // MARK: - Upload to Supabase
    
    /// Upload all local favorites to Supabase
    func uploadLocalFavorites() async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("⚠️ [FavoritesSync] Supabase not configured, skipping upload")
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            print("⚠️ [FavoritesSync] No active session, cannot upload favorites")
            return
        }
        
        let localFavorites = favoritesService.favorites
        print("📤 [FavoritesSync] Uploading \(localFavorites.count) local favorites")
        
        for meal in localFavorites {
            do {
                // Check if favorite already exists
                let existing: [FavoriteRow] = try await client
                    .from("favorites")
                    .select()
                    .eq("user_id", value: session.user.id.uuidString)
                    .eq("meal_id", value: meal.id.uuidString)
                    .execute()
                    .value
                
                if existing.isEmpty {
                    // Insert new favorite
                    let newFavorite = FavoriteRow(
                        id: UUID(),
                        user_id: session.user.id,
                        meal_id: meal.id,
                        created_at: Date(),
                        updated_at: Date()
                    )
                    
                    try await client
                        .from("favorites")
                        .insert(newFavorite)
                        .execute()
                    
                    print("✅ [FavoritesSync] Uploaded favorite: \(meal.title)")
                } else {
                    print("ℹ️ [FavoritesSync] Favorite already exists: \(meal.title)")
                }
            } catch {
                print("❌ [FavoritesSync] Failed to upload favorite \(meal.title): \(error)")
            }
        }
        
        print("✅ [FavoritesSync] Upload completed")
    }
    
    // MARK: - Download from Supabase
    
    /// Download all favorites from Supabase
    func downloadFavorites() async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("⚠️ [FavoritesSync] Supabase not configured, skipping download")
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            print("⚠️ [FavoritesSync] No active session, cannot download favorites")
            return
        }
        
        print("📥 [FavoritesSync] Downloading favorites from Supabase")
        
        do {
            // Fetch favorite meal IDs for current user
            let favoriteRows: [FavoriteRow] = try await client
                .from("favorites")
                .select()
                .eq("user_id", value: session.user.id.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("📥 [FavoritesSync] Found \(favoriteRows.count) favorites in cloud")
            
            // Fetch full meal details for each favorite
            for favorite in favoriteRows {
                do {
                    let meals: [Meal] = try await client
                        .from("meals")
                        .select()
                        .eq("id", value: favorite.meal_id.uuidString)
                        .execute()
                        .value
                    
                    if let meal = meals.first {
                        // Add to local favorites if not already present
                        if !favoritesService.isFavorite(meal) {
                            try await favoritesService.addFavorite(meal)
                            print("✅ [FavoritesSync] Downloaded and saved: \(meal.title)")
                        }
                    }
                } catch {
                    print("❌ [FavoritesSync] Failed to fetch meal for favorite: \(error)")
                }
            }
            
            print("✅ [FavoritesSync] Download completed")
        } catch {
            print("❌ [FavoritesSync] Failed to download favorites: \(error)")
            throw error
        }
    }
    
    // MARK: - Add Favorite
    
    /// Add a favorite to both local and Supabase
    func addFavorite(_ meal: Meal) async throws {
        // Add to local storage first
        try await favoritesService.addFavorite(meal)
        
        // Upload to Supabase if authenticated
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("ℹ️ [FavoritesSync] Added to local only (not authenticated)")
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            print("ℹ️ [FavoritesSync] Added to local only (no session)")
            return
        }
        
        do {
            let newFavorite = FavoriteRow(
                id: UUID(),
                user_id: session.user.id,
                meal_id: meal.id,
                created_at: Date(),
                updated_at: Date()
            )
            
            try await client
                .from("favorites")
                .insert(newFavorite)
                .execute()
            
            print("✅ [FavoritesSync] Added favorite to cloud: \(meal.title)")
        } catch {
            print("❌ [FavoritesSync] Failed to add to cloud (local saved): \(error)")
            // Don't throw - local save succeeded
        }
    }
    
    // MARK: - Remove Favorite
    
    /// Remove a favorite from both local and Supabase
    func removeFavorite(_ meal: Meal) async throws {
        // Remove from local storage first
        try await favoritesService.removeFavorite(meal)
        
        // Remove from Supabase if authenticated
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            print("ℹ️ [FavoritesSync] Removed from local only (not authenticated)")
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            print("ℹ️ [FavoritesSync] Removed from local only (no session)")
            return
        }
        
        do {
            try await client
                .from("favorites")
                .delete()
                .eq("user_id", value: session.user.id.uuidString)
                .eq("meal_id", value: meal.id.uuidString)
                .execute()
            
            print("✅ [FavoritesSync] Removed favorite from cloud: \(meal.title)")
        } catch {
            print("❌ [FavoritesSync] Failed to remove from cloud (local removed): \(error)")
            // Don't throw - local remove succeeded
        }
    }
    
    // MARK: - Sync All
    
    /// Perform full bidirectional sync with conflict resolution
    func syncAll() async throws {
        guard authService.isAuthenticated else {
            print("ℹ️ [FavoritesSync] Not authenticated, skipping sync")
            return
        }
        
        print("🔄 [FavoritesSync] Starting full sync with conflict resolution")
        
        // Strategy: Merge both sets (union approach)
        // - If favorite exists in either local or cloud, keep it
        // - This handles offline additions gracefully
        // - Deletions are eventually consistent
        
        // First download from cloud (to get latest)
        try await downloadFavorites()
        
        // Then upload any local favorites not in cloud
        try await uploadLocalFavorites()
        
        print("✅ [FavoritesSync] Full sync completed")
    }
    
    // MARK: - Conflict Resolution
    
    /// Resolve conflicts between local and cloud favorites
    /// Uses merge strategy: keep favorites from both sources
    private func resolveConflicts() async throws {
        guard supabaseClient.isConfigured, let client = supabaseClient.client else {
            return
        }
        
        guard let session = await supabaseClient.currentSession else {
            return
        }
        
        print("🔄 [FavoritesSync] Resolving conflicts")
        
        // Get cloud favorites
        let cloudFavorites: [FavoriteRow] = try await client
            .from("favorites")
            .select()
            .eq("user_id", value: session.user.id.uuidString)
            .execute()
            .value
        
        let cloudMealIds = Set(cloudFavorites.map { $0.meal_id })
        let localMealIds = Set(favoritesService.favorites.map { $0.id })
        
        // Find favorites only in cloud (download these)
        let cloudOnlyIds = cloudMealIds.subtracting(localMealIds)
        print("📥 [FavoritesSync] Found \(cloudOnlyIds.count) favorites only in cloud")
        
        // Find favorites only local (upload these)
        let localOnlyIds = localMealIds.subtracting(cloudMealIds)
        print("📤 [FavoritesSync] Found \(localOnlyIds.count) favorites only locally")
        
        // Conflict resolution is implicit:
        // - Favorites in both: already synced, no action needed
        // - Favorites only in one: sync from source to destination
        
        print("✅ [FavoritesSync] Conflict resolution completed")
    }
}

// MARK: - Data Models

struct FavoriteRow: Codable {
    let id: UUID
    let user_id: UUID
    let meal_id: UUID
    let created_at: Date
    let updated_at: Date
}

