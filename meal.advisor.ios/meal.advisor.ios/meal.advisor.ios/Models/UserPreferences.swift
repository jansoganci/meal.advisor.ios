//
//  UserPreferences.swift
//  meal.advisor.ios
//
//  Preferences model aligned with project_structure.md
//

import Foundation

struct UserPreferences: Codable, Equatable {
    var dietaryRestrictions: Set<Meal.DietType>
    var cuisinePreferences: Set<Meal.Cuisine>
    var maxCookingTime: Int                    // minutes
    var difficultyPreference: Meal.Difficulty?
    var excludedIngredients: Set<String>

    static let `default` = UserPreferences(
        dietaryRestrictions: [],
        cuisinePreferences: Set(Meal.Cuisine.allCases),
        maxCookingTime: 60,
        difficultyPreference: nil,
        excludedIngredients: []
    )
}
