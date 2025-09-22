//
//  Meal.swift
//  meal.advisor.ios
//
//  Expanded meal model aligned with project_structure.md
//

import Foundation

struct Meal: Identifiable, Codable {
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

    enum Difficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }

    enum Cuisine: String, CaseIterable, Codable {
        case italian = "Italian"
        case american = "American"
        case asian = "Asian"
        case mediterranean = "Mediterranean"
        case mexican = "Mexican"
    }

    enum DietType: String, CaseIterable, Codable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case lowCarb = "Low-Carb"
        case highProtein = "High-Protein"
        case paleo = "Paleo"
        case lowSodium = "Low-Sodium"
        case quickEasy = "Quick & Easy"
    }
}

struct Ingredient: Identifiable, Codable {
    var id: UUID { UUID() } // Generate ID on-the-fly for Identifiable protocol
    let name: String
    let amount: String
    let unit: String
    
    // Only decode the fields that exist in JSON
    private enum CodingKeys: String, CodingKey {
        case name, amount, unit
    }
}

struct NutritionInfo: Codable {
    let calories: Int?
    let protein: Int?    // grams
    let carbs: Int?      // grams
    let fat: Int?        // grams
}
