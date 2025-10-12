//
//  Meal.swift
//  meal.advisor.ios
//
//  Expanded meal model aligned with project_structure.md
//

import Foundation

// 🔒 THREAD SAFETY: Sendable conformance for safe concurrent access
// 🎯 STATE MANAGEMENT: Equatable for state comparison and SwiftUI diffing
struct Meal: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let prepTime: Int              // minutes
    let difficulty: Difficulty
    let cuisine: Cuisine
    let dietTags: [DietType]
    let imageURL: URL?
    let ingredients: [Ingredient]
    let instructions: [String]
    let nutritionInfo: NutritionInfo?
    
    // Handle camelCase JSON keys from Edge Function response
    private enum CodingKeys: String, CodingKey {
        case id, title, description, prepTime, difficulty, cuisine, dietTags, imageURL, ingredients, instructions, nutritionInfo
    }

    enum Difficulty: String, CaseIterable, Codable, Sendable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }

    enum Cuisine: String, CaseIterable, Codable, Sendable {
        case italian = "Italian"
        case turkish = "Turkish"
        case chinese = "Chinese"
        case japanese = "Japanese"
        case french = "French"
        case thai = "Thai"
        case indian = "Indian"
        case mexican = "Mexican"
        case spanish = "Spanish"
        case american = "American"
        case asian = "Asian"  // Legacy support for old cached data
        case mediterranean = "Mediterranean"  // Legacy support for old cached data
    }

    enum DietType: String, CaseIterable, Codable, Sendable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case noPork = "No Pork"
        case lowCarb = "Low-Carb"
        case highProtein = "High-Protein"
        case paleo = "Paleo"
        case lowSodium = "Low-Sodium"
        case quickEasy = "Quick & Easy"
    }
}

struct Ingredient: Identifiable, Codable, Sendable, Equatable {
    var id: UUID { UUID() } // Generate ID on-the-fly for Identifiable protocol
    
    // Equatable implementation (compare all stored properties except computed id)
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.name == rhs.name && lhs.amount == rhs.amount && lhs.unit == rhs.unit
    }
    let name: String
    let amount: String
    let unit: String
    
    // Only decode the fields that exist in JSON
    private enum CodingKeys: String, CodingKey {
        case name, amount, unit
    }
}

struct NutritionInfo: Codable, Sendable, Equatable {
    let calories: Int?
    let protein: Int?    // grams
    let carbs: Int?      // grams
    let fat: Int?        // grams
}
