//
//  Secrets.swift
//  meal.advisor.ios
//
//  Loads Supabase config from Secrets.plist if present (not in repo).
//  A Secrets.example.plist is provided under Resources.
//

import Foundation

struct SecretsConfig {
    static let shared = SecretsConfig()

    let supabaseURL: URL?
    let supabaseAnonKey: String?

    init() {
        // Secrets.plist is optional; if missing, these will be nil.
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any] {
            if let urlString = dict["SUPABASE_URL"] as? String { supabaseURL = URL(string: urlString) } else { supabaseURL = nil }
            supabaseAnonKey = dict["SUPABASE_ANON_KEY"] as? String
        } else {
            supabaseURL = nil
            supabaseAnonKey = nil
        }
    }
}

