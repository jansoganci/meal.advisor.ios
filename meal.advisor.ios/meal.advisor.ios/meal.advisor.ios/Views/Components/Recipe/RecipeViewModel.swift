//
//  RecipeViewModel.swift
//  meal.advisor.ios
//
//  ViewModel for recipe detail screen with clean state management
//

import Foundation
import SwiftUI

@MainActor
final class RecipeViewModel: ObservableObject {
    @Published var meal: Meal
    @Published var isImageLoading = false
    @Published var imageLoadError = false
    
    init(meal: Meal) {
        self.meal = meal
    }
    
    // MARK: - Computed Properties
    
    var formattedPrepTime: String {
        if meal.prepTime < 60 {
            return "\(meal.prepTime) min"
        } else {
            let hours = meal.prepTime / 60
            let minutes = meal.prepTime % 60
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
    }
    
    var difficultyColor: Color {
        switch meal.difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    var cuisineEmoji: String {
        switch meal.cuisine {
        case .italian:
            return "🇮🇹"
        case .turkish:
            return "🇹🇷"
        case .chinese:
            return "🥢"
        case .japanese:
            return "🍣"
        case .french:
            return "🥖"
        case .thai:
            return "🌶️"
        case .indian:
            return "🍛"
        case .mexican:
            return "🌮"
        case .spanish:
            return "🇪🇸"
        case .american:
            return "🇺🇸"
        case .asian:
            return "🍜"  // General Asian cuisine
        case .mediterranean:
            return "🫒"  // Mediterranean cuisine
        }
    }
    
    var hasNutritionInfo: Bool {
        meal.nutritionInfo != nil
    }
    
    var totalCalories: Int {
        meal.nutritionInfo?.calories ?? 0
    }
    
    var proteinGrams: Int {
        meal.nutritionInfo?.protein ?? 0
    }
    
    var carbsGrams: Int {
        meal.nutritionInfo?.carbs ?? 0
    }
    
    var fatGrams: Int {
        meal.nutritionInfo?.fat ?? 0
    }
    
    // MARK: - Methods
    
    func onImageLoadStart() {
        isImageLoading = true
        imageLoadError = false
    }
    
    func onImageLoadSuccess() {
        isImageLoading = false
        imageLoadError = false
    }
    
    func onImageLoadError() {
        isImageLoading = false
        imageLoadError = true
    }
    
    func shareRecipe() -> String {
        var shareText = "\(meal.title)\n\n"
        shareText += "\(meal.description)\n\n"
        shareText += "⏱️ \(formattedPrepTime) • 👨‍🍳 \(meal.difficulty.rawValue) • \(cuisineEmoji) \(meal.cuisine.rawValue)\n\n"
        shareText += "Ingredients:\n"
        
        for ingredient in meal.ingredients {
            shareText += "• \(ingredient.amount) \(ingredient.unit) \(ingredient.name)\n"
        }
        
        shareText += "\nInstructions:\n"
        for (index, instruction) in meal.instructions.enumerated() {
            shareText += "\(index + 1). \(instruction)\n"
        }
        
        if hasNutritionInfo {
            shareText += "\nNutrition: \(totalCalories) cal • \(proteinGrams)g protein • \(carbsGrams)g carbs • \(fatGrams)g fat"
        }
        
        return shareText
    }
}
