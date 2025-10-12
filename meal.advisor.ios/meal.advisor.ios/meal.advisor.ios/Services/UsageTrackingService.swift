//
//  UsageTrackingService.swift
//  meal.advisor.ios
//
//  Usage quota tracking for free/premium tier enforcement
//  Tracks daily suggestion count per user (authenticated) or device (anonymous)
//

import Foundation

// MARK: - UsageState

/// 🎯 STATE MANAGEMENT: Single state struct for atomic UI updates
/// Reduces view rebuilds from 3 updates to 1 update per operation
struct UsageState: Equatable {
    var dailyUsageCount: Int = 0
    var hasReachedLimit: Bool = false
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    var remainingCount: Int {
        max(0, 5 - dailyUsageCount)
    }
    
    var progressPercentage: Double {
        min(1.0, Double(dailyUsageCount) / 5.0)
    }
    
    var canGenerate: Bool {
        !hasReachedLimit && dailyUsageCount < 5
    }
    
    var usageDescription: String {
        "\(dailyUsageCount)/5 suggestions used today"
    }
}

// MARK: - UsageTrackingService

@MainActor
final class UsageTrackingService: ObservableObject {
    static let shared = UsageTrackingService()
    
    // 🎯 STATE MANAGEMENT: Single @Published property replaces 3 separate properties
    // This reduces view rebuilds by ~67% (from 3 updates to 1 update)
    @Published var state = UsageState()
    
    // MARK: - Constants
    
    private let FREE_DAILY_LIMIT = 5
    private let CACHE_KEY_USAGE_COUNT = "usage_tracking_daily_count"
    private let CACHE_KEY_LAST_RESET = "usage_tracking_last_reset_date"
    private let CACHE_KEY_LAST_SYNC = "usage_tracking_last_sync_timestamp"
    
    // MARK: - Dependencies
    
    private let supabaseClient = SupabaseClientManager.shared
    private let authService = AuthService.shared
    private let purchaseService = PurchaseService.shared
    private let defaults = UserDefaults.standard
    
    // MARK: - Private State
    
    private var midnightResetTimer: Timer?
    private var lastKnownDate: Date?
    
    // MARK: - Initialization
    
    private init() {
        // Load cached usage count
        loadCachedUsage()
        
        // Check if date changed (handles app backgrounding)
        checkDateChange()
        
        // Schedule midnight reset timer
        scheduleMidnightReset()
        
        // Fetch latest usage from server
        Task {
            await refreshUsageCount()
        }
        
        print("📊 [UsageTracking] Service initialized")
        print("📊 [UsageTracking] Cached daily count: \(state.dailyUsageCount)")
        print("📊 [UsageTracking] Free tier limit: \(FREE_DAILY_LIMIT)")
    }
    
    deinit {
        midnightResetTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Check if user can generate another suggestion
    func canGenerateSuggestion() async -> Bool {
        // Premium users always have unlimited suggestions
        if purchaseService.subscriptionStatus.isPremium {
            print("📊 [UsageTracking] ✅ Premium user - unlimited access")
            return true
        }
        
        // Refresh count from server before checking (ensures accuracy)
        await refreshUsageCount()
        
        let canGenerate = state.dailyUsageCount < FREE_DAILY_LIMIT
        
        if canGenerate {
            print("📊 [UsageTracking] ✅ Can generate (\(state.dailyUsageCount)/\(FREE_DAILY_LIMIT))")
        } else {
            print("📊 [UsageTracking] ❌ Limit reached (\(state.dailyUsageCount)/\(FREE_DAILY_LIMIT))")
            state.hasReachedLimit = true
        }
        
        return canGenerate
    }
    
    /// Track a suggestion usage (increment counter)
    func trackSuggestionUsage() async throws {
        // Premium users don't need tracking (unlimited)
        if purchaseService.subscriptionStatus.isPremium {
            print("📊 [UsageTracking] Premium user - skipping usage tracking")
            return
        }
        
        // Increment local count
        state.dailyUsageCount += 1
        saveCachedUsage()
        
        print("📊 [UsageTracking] Incremented count to \(state.dailyUsageCount)/\(FREE_DAILY_LIMIT)")
        
        // Update server in background
        Task.detached(priority: .background) { @MainActor in
            do {
                try await self.syncUsageToServer()
                print("📊 [UsageTracking] ✅ Synced to server: \(self.state.dailyUsageCount)")
            } catch {
                print("📊 [UsageTracking] ⚠️ Failed to sync to server: \(error)")
                // Don't throw - offline is OK, we'll sync later
            }
        }
    }
    
    /// Get remaining suggestions for today
    func getRemainingCount() -> Int {
        // Premium users have unlimited
        if purchaseService.subscriptionStatus.isPremium {
            return Int.max // Unlimited
        }
        
        return max(0, FREE_DAILY_LIMIT - state.dailyUsageCount)
    }
    
    /// Refresh usage count from server
    func refreshUsageCount() async {
        // Premium users don't need quota tracking
        if purchaseService.subscriptionStatus.isPremium {
            state.dailyUsageCount = 0
            state.hasReachedLimit = false
            return
        }
        
        do {
            let count = try await fetchTodayUsageFromServer()
            state.dailyUsageCount = count
            state.hasReachedLimit = count >= FREE_DAILY_LIMIT
            saveCachedUsage()
            
            print("📊 [UsageTracking] ✅ Refreshed from server: \(count)/\(FREE_DAILY_LIMIT)")
        } catch {
            print("📊 [UsageTracking] ⚠️ Failed to refresh from server: \(error)")
            // Use cached value (graceful degradation)
        }
    }
    
    /// Reset daily counter (called at midnight or on date change)
    func resetDailyCounter() {
        print("📊 [UsageTracking] 🔄 Resetting daily counter")
        
        state.dailyUsageCount = 0
        state.hasReachedLimit = false
        saveCachedUsage()
        
        // Update last reset date
        let today = Calendar.current.startOfDay(for: Date())
        defaults.set(today, forKey: CACHE_KEY_LAST_RESET)
        
        print("📊 [UsageTracking] ✅ Counter reset for new day")
    }
    
    // MARK: - Server Sync Methods
    
    /// Fetch today's usage count from Supabase
    private func fetchTodayUsageFromServer() async throws -> Int {
        guard supabaseClient.isConfigured,
              let client = supabaseClient.client else {
            print("📊 [UsageTracking] Supabase not configured - using cached value")
            throw UsageTrackingError.supabaseNotConfigured
        }
        
        let identifier = getUserIdentifier()
        let today = ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for: Date()))
        
        print("📊 [UsageTracking] Fetching usage for \(identifier.type): \(identifier.value)")
        
        // Query usage_tracking table
        let query = client
            .from("usage_tracking")
            .select()
            .eq(identifier.type, value: identifier.value)
            .eq("tracking_date", value: today)
            .single()
        
        do {
            struct UsageRecord: Codable {
                let suggestionCount: Int
                
                enum CodingKeys: String, CodingKey {
                    case suggestionCount = "suggestion_count"
                }
            }
            
            let response: UsageRecord = try await query.execute().value
            return response.suggestionCount
        } catch {
            // No record found for today = 0 usage
            if error.localizedDescription.contains("No rows") || error.localizedDescription.contains("PGRST116") {
                print("📊 [UsageTracking] No usage record for today - starting at 0")
                return 0
            }
            
            print("📊 [UsageTracking] Error fetching usage: \(error)")
            throw error
        }
    }
    
    /// Update usage count on server
    private func syncUsageToServer() async throws {
        guard supabaseClient.isConfigured,
              let client = supabaseClient.client else {
            print("📊 [UsageTracking] Supabase not configured - skipping sync")
            throw UsageTrackingError.supabaseNotConfigured
        }
        
        let identifier = getUserIdentifier()
        let today = Calendar.current.startOfDay(for: Date())
        
        print("📊 [UsageTracking] Syncing usage: \(state.dailyUsageCount) for \(identifier.type)")
        
        // Prepare usage record based on identifier type
        // Note: We use upsert with onConflict to update existing records
        if identifier.type == "user_id", let uuid = UUID(uuidString: identifier.value) {
            let record = UsageTrackingRow(
                id: UUID(),  // Will be ignored if record exists
                user_id: uuid,
                device_id: nil,
                tracking_date: today,
                suggestion_count: state.dailyUsageCount,
                created_at: Date(),
                updated_at: Date()
            )
            
            // Upsert with conflict resolution on user_id and tracking_date
            try await client
                .from("usage_tracking")
                .upsert(record, onConflict: "user_id,tracking_date")
                .execute()
        } else {
            let record = UsageTrackingRow(
                id: UUID(),  // Will be ignored if record exists
                user_id: nil,
                device_id: identifier.value,
                tracking_date: today,
                suggestion_count: state.dailyUsageCount,
                created_at: Date(),
                updated_at: Date()
            )
            
            // Upsert with conflict resolution on device_id and tracking_date
            try await client
                .from("usage_tracking")
                .upsert(record, onConflict: "device_id,tracking_date")
                .execute()
        }
        
        // Update last sync timestamp
        defaults.set(Date(), forKey: CACHE_KEY_LAST_SYNC)
        
        print("📊 [UsageTracking] ✅ Synced to server successfully")
    }
    
    // MARK: - Helper Methods
    
    /// Get user identifier (user_id if authenticated, device_id if anonymous)
    private func getUserIdentifier() -> (type: String, value: String) {
        if authService.isAuthenticated, let user = authService.currentUser {
            return ("user_id", user.id)
        } else {
            return ("device_id", authService.deviceID)
        }
    }
    
    /// Check if date changed since last launch (handles app backgrounding)
    private func checkDateChange() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastReset = defaults.object(forKey: CACHE_KEY_LAST_RESET) as? Date {
            let lastResetDay = Calendar.current.startOfDay(for: lastReset)
            
            if today > lastResetDay {
                print("📊 [UsageTracking] 🗓️ Date changed - resetting counter")
                resetDailyCounter()
            }
        } else {
            // First launch - set initial reset date
            defaults.set(today, forKey: CACHE_KEY_LAST_RESET)
        }
        
        lastKnownDate = today
    }
    
    /// Schedule timer to check for midnight reset
    private func scheduleMidnightReset() {
        // Cancel existing timer
        midnightResetTimer?.invalidate()
        
        // Check every 60 seconds if date changed
        midnightResetTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                let today = Calendar.current.startOfDay(for: Date())
                
                if let lastKnown = self.lastKnownDate, today > lastKnown {
                    print("📊 [UsageTracking] ⏰ Midnight passed - resetting counter")
                    self.resetDailyCounter()
                    self.lastKnownDate = today
                }
            }
        }
        
        print("📊 [UsageTracking] ⏰ Scheduled midnight reset timer")
    }
    
    // MARK: - Local Cache Methods
    
    /// Load cached usage count from UserDefaults
    private func loadCachedUsage() {
        state.dailyUsageCount = defaults.integer(forKey: CACHE_KEY_USAGE_COUNT)
        state.hasReachedLimit = state.dailyUsageCount >= FREE_DAILY_LIMIT
        
        print("📊 [UsageTracking] Loaded cached usage: \(state.dailyUsageCount)")
    }
    
    /// Save usage count to UserDefaults
    private func saveCachedUsage() {
        defaults.set(state.dailyUsageCount, forKey: CACHE_KEY_USAGE_COUNT)
        state.hasReachedLimit = state.dailyUsageCount >= FREE_DAILY_LIMIT
    }
    
    // MARK: - Migration Methods
    
    /// Migrate device usage to user account on sign-in
    func migrateDeviceUsageToUser() async {
        guard authService.isAuthenticated, let user = authService.currentUser else {
            print("📊 [UsageTracking] Cannot migrate - user not authenticated")
            return
        }
        
        print("📊 [UsageTracking] 🔄 Migrating device usage to user account")
        
        do {
            guard supabaseClient.isConfigured,
                  let client = supabaseClient.client else {
                print("📊 [UsageTracking] Supabase not configured - skipping migration")
                return
            }
            
            let deviceID = authService.deviceID
            let today = ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for: Date()))
            
            // Check if device has usage today
            let query = client
                .from("usage_tracking")
                .select()
                .eq("device_id", value: deviceID)
                .eq("tracking_date", value: today)
                .single()
            
            struct UsageRecord: Codable {
                let suggestionCount: Int
                
                enum CodingKeys: String, CodingKey {
                    case suggestionCount = "suggestion_count"
                }
            }
            
            let deviceUsage: UsageRecord = try await query.execute().value
            
            // Migrate to user account
            let todayDate = Calendar.current.startOfDay(for: Date())
            let record = UsageTrackingRow(
                id: UUID(),
                user_id: UUID(uuidString: user.id),
                device_id: nil,
                tracking_date: todayDate,
                suggestion_count: deviceUsage.suggestionCount,
                created_at: Date(),
                updated_at: Date()
            )
            
            try await client
                .from("usage_tracking")
                .upsert(record)
                .execute()
            
            // Delete device record
            try await client
                .from("usage_tracking")
                .delete()
                .eq("device_id", value: deviceID)
                .eq("tracking_date", value: today)
                .execute()
            
            print("📊 [UsageTracking] ✅ Migrated \(deviceUsage.suggestionCount) suggestions from device to user")
            
        } catch {
            // Migration failed - not critical, just log
            print("📊 [UsageTracking] ⚠️ Migration failed (non-critical): \(error)")
        }
    }
}

// MARK: - Errors

enum UsageTrackingError: LocalizedError {
    case supabaseNotConfigured
    case quotaExceeded
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .supabaseNotConfigured:
            return "Usage tracking service is not available. Please check your internet connection."
        case .quotaExceeded:
            return "Daily suggestion limit reached. Upgrade to Premium for unlimited suggestions."
        case .networkError:
            return "Unable to sync usage data. Please check your internet connection."
        }
    }
}

// MARK: - Data Models

struct UsageTrackingRow: Codable {
    let id: UUID
    let user_id: UUID?
    let device_id: String?
    let tracking_date: Date
    let suggestion_count: Int
    let created_at: Date
    let updated_at: Date
}

