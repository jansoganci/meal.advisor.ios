//
//  meal_advisor_iosApp.swift
//  meal.advisor.ios
//
//  Created by Can Soğancı on 21.09.2025.
//

import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

@main
struct meal_advisor_iosApp: App {
    init() {
        // Setup notification categories on app launch
        NotificationService.shared.setupNotificationCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Handle OAuth callback URL
                    print("🔗 [OAuth Callback Step 1] Received URL callback")
                    print("🔗 [OAuth Callback Step 1] Full URL: \(url)")
                    print("🔗 [OAuth Callback Step 1] URL scheme: \(url.scheme ?? "none")")
                    print("🔗 [OAuth Callback Step 1] URL host: \(url.host ?? "none")")
                    print("🔗 [OAuth Callback Step 1] URL path: \(url.path)")
                    print("🔗 [OAuth Callback Step 1] URL query: \(url.query ?? "none")")
                    print("🔗 [OAuth Callback Step 1] URL fragment: \(url.fragment ?? "none")")
                    
                    // Parse and log query parameters
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let queryItems = components.queryItems {
                        print("🔗 [OAuth Callback Step 1] Query parameters:")
                        for item in queryItems {
                            if let value = item.value {
                                print("🔗 [OAuth Callback Step 1]   \(item.name): \(value)")
                            }
                        }
                    }
                    
                    // Check if this is a Supabase callback URL or custom scheme
                    let isSupabaseCallback = url.host == "lsgkepyywqsruelusrku.supabase.co" && url.path.contains("/auth/v1/callback")
                    let isCustomSchemeCallback = url.scheme == "mealadvisor" && url.host == "auth" && url.path.contains("callback")
                    
                    print("🔗 [OAuth Callback Step 2] Checking callback type...")
                    print("🔗 [OAuth Callback Step 2] Is Supabase callback: \(isSupabaseCallback)")
                    print("🔗 [OAuth Callback Step 2] Is custom scheme callback: \(isCustomSchemeCallback)")
                    
                    if isSupabaseCallback || isCustomSchemeCallback {
                        print("✅ [OAuth Callback Step 2] OAuth callback detected")
                        print("🔗 [OAuth Callback Step 3] Processing OAuth session...")
                        
                        Task {
                            do {
                                if let client = SupabaseClientManager.shared.client {
                                    print("✅ [OAuth Callback Step 3] Supabase client available")
                                    print("🔗 [OAuth Callback Step 4] Calling client.auth.session(from: url)")
                                    
                                    let session = try await client.auth.session(from: url)
                                    
                                    print("✅ [OAuth Callback Step 4] OAuth session created successfully")
                                    print("✅ [OAuth Callback Step 4] Session user ID: \(session.user.id)")
                                    print("✅ [OAuth Callback Step 4] Session user email: \(session.user.email ?? "none")")
                                    print("✅ [OAuth Callback Step 4] Session access token: \(session.accessToken.prefix(20))...")
                                    print("✅ [OAuth Callback Step 4] Session refresh token: \(session.refreshToken.prefix(20))...")
                                    
                                    print("🔗 [OAuth Callback Step 5] Updating AuthService state...")
                                    // Update AuthService state
                                    await AuthService.shared.handleOAuthCallback(session: session)
                                    print("✅ [OAuth Callback Step 5] AuthService state updated successfully")
                                    
                                } else {
                                    print("❌ [OAuth Callback Step 3] Supabase client not available")
                                }
                            } catch {
                                print("❌ [OAuth Callback Step 4] Failed to handle OAuth callback")
                                print("❌ [OAuth Callback Step 4] Error type: \(type(of: error))")
                                print("❌ [OAuth Callback Step 4] Error description: \(error.localizedDescription)")
                                print("❌ [OAuth Callback Step 4] Full error: \(error)")
                                
                                // Check if it's a specific error with more details
                                print("❌ [OAuth Callback Step 4] Error details: \(error)")
                                
                                // Check if it's a JSON decoding error
                                if let decodingError = error as? DecodingError {
                                    print("❌ [OAuth Callback Step 4] JSON decoding error: \(decodingError)")
                                }
                            }
                        }
                    } else {
                        print("🔗 [OAuth Callback Step 2] Not an OAuth callback URL, ignoring")
                        print("🔗 [OAuth Callback Step 2] Expected: Supabase callback or mealadvisor://auth/callback")
                    }
                }
        }
    }
}
