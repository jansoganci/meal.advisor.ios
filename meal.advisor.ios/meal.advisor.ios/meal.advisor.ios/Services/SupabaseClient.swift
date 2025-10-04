//
//  SupabaseClient.swift
//  meal.advisor.ios
//
//  Centralized Supabase client wrapper for authentication and database operations
//

import Foundation
#if canImport(Supabase)
import Supabase
#endif

@MainActor
final class SupabaseClientManager {
    static let shared = SupabaseClientManager()
    
    // Supabase client instance
    private(set) var client: SupabaseClient?
    
    // Check if Supabase is configured
    var isConfigured: Bool {
        return client != nil
    }
    
    private init() {
        initializeClient()
    }
    
    // MARK: - Initialization
    
    private func initializeClient() {
        print("🔧 [SupabaseClient] Initializing Supabase client...")
        
        guard let url = SecretsConfig.shared.supabaseURL,
              let anonKey = SecretsConfig.shared.supabaseAnonKey else {
            print("⚠️ [SupabaseClient] Supabase credentials not found in environment variables")
            print("⚠️ [SupabaseClient] Make sure Config.xcconfig exists with SUPABASE_URL and SUPABASE_ANON_KEY")
            return
        }
        
        print("✅ [SupabaseClient] Supabase credentials loaded from environment variables")
        print("✅ [SupabaseClient] Project URL: \(url.absoluteString)")
        print("✅ [SupabaseClient] Anon Key: \(anonKey.prefix(20))...")
        
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
        
        print("✅ [SupabaseClient] Supabase client initialized successfully")
        print("✅ [SupabaseClient] Client URL: \(url.absoluteString)")
        
        // Setup auth state listener
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        guard let client = client else { return }
        
        Task {
            for await state in client.auth.authStateChanges {
                print("🔐 [SupabaseClient] Auth state changed: \(state.event)")
                
                switch state.event {
                case .signedIn:
                    print("✅ [SupabaseClient] User signed in: \(state.session?.user.id.uuidString ?? "unknown")")
                case .signedOut:
                    print("👋 [SupabaseClient] User signed out")
                case .initialSession:
                    print("🔄 [SupabaseClient] Initial session loaded")
                case .tokenRefreshed:
                    print("🔄 [SupabaseClient] Token refreshed")
                case .userUpdated:
                    print("👤 [SupabaseClient] User updated")
                case .passwordRecovery:
                    print("🔑 [SupabaseClient] Password recovery")
                case .userDeleted:
                    print("🗑️ [SupabaseClient] User deleted")
                case .mfaChallengeVerified:
                    print("🔐 [SupabaseClient] MFA challenge verified")
                @unknown default:
                    print("❓ [SupabaseClient] Unknown auth event")
                }
            }
        }
    }
    
    // MARK: - Session Management
    
    /// Get current auth session
    var currentSession: Session? {
        get async {
            guard let client = client else { return nil }
            
            do {
                let session = try await client.auth.session
                return session
            } catch {
                print("❌ [SupabaseClient] Failed to get session: \(error)")
                return nil
            }
        }
    }
    
    /// Get current authenticated user
    func getCurrentUser() async -> User? {
        guard let session = await currentSession else { return nil }
        return session.user
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        get async {
            return await currentSession != nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Refresh the current session
    func refreshSession() async throws {
        guard let client = client else {
            throw SupabaseClientError.notConfigured
        }
        
        do {
            let session = try await client.auth.refreshSession()
            print("✅ [SupabaseClient] Session refreshed for user: \(session.user.id.uuidString)")
        } catch {
            print("❌ [SupabaseClient] Failed to refresh session: \(error)")
            throw error
        }
    }
    
    /// Sign out current user
    func signOut() async throws {
        guard let client = client else {
            throw SupabaseClientError.notConfigured
        }
        
        do {
            try await client.auth.signOut()
            print("✅ [SupabaseClient] User signed out successfully")
        } catch {
            print("❌ [SupabaseClient] Failed to sign out: \(error)")
            throw error
        }
    }
}

// MARK: - Errors

enum SupabaseClientError: LocalizedError {
    case notConfigured
    case sessionNotFound
    case authenticationFailed
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase client is not configured. Please check your credentials."
        case .sessionNotFound:
            return "No active session found. Please sign in again."
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        }
    }
}

