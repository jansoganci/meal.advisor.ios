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
}

