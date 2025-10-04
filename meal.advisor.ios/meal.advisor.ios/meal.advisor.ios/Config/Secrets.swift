//
//  Secrets.swift
//  meal.advisor.ios
//
//  Loads API keys and secrets from environment variables (Config.xcconfig).
//  Secure configuration management for production builds.
//

import Foundation

struct SecretsConfig {
    static let shared = SecretsConfig()

    let supabaseURL: URL?
    let supabaseAnonKey: String?
    let googleClientID: String?
    let googleClientSecret: String?
    let appleServiceID: String?
    let appleKeyID: String?
    let appleTeamID: String?
    let applePrivateKey: String?

    init() {
        // Load from Secrets.plist file
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) else {
            print("⚠️ [SecretsConfig] Secrets.plist not found")
            supabaseURL = nil
            supabaseAnonKey = nil
            googleClientID = nil
            googleClientSecret = nil
            appleServiceID = nil
            appleKeyID = nil
            appleTeamID = nil
            applePrivateKey = nil
            return
        }
        
        // Parse Supabase URL
        if let urlString = plist["SUPABASE_URL"] as? String {
            supabaseURL = URL(string: urlString)
        } else {
            supabaseURL = nil
        }
        
        // Load all other secrets from plist
        supabaseAnonKey = plist["SUPABASE_ANON_KEY"] as? String
        googleClientID = plist["GOOGLE_CLIENT_ID"] as? String
        googleClientSecret = plist["GOOGLE_CLIENT_SECRET"] as? String
        appleServiceID = plist["APPLE_SERVICE_ID"] as? String
        appleKeyID = plist["APPLE_KEY_ID"] as? String
        appleTeamID = plist["APPLE_TEAM_ID"] as? String
        
        // Handle multi-line private key
        if let privateKey = plist["APPLE_PRIVATE_KEY"] as? String {
            applePrivateKey = privateKey
        } else {
            applePrivateKey = nil
        }
    }
}

