//
//  NutritionBadges.swift
//  meal.advisor.ios
//
//  Clean, minimal nutrition information and diet tags display
//

import SwiftUI

struct NutritionBadges: View {
    let nutritionInfo: NutritionInfo?
    let dietTags: [Meal.DietType]
    let prepTime: Int
    let difficulty: Meal.Difficulty
    let cuisine: Meal.Cuisine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recipe Metadata
            RecipeMetadataRow(
                prepTime: prepTime,
                difficulty: difficulty,
                cuisine: cuisine
            )
            
            // Nutrition Information
            if let nutrition = nutritionInfo {
                NutritionInfoRow(nutrition: nutrition)
            }
            
            // Diet Tags
            if !dietTags.isEmpty {
                DietTagsRow(dietTags: dietTags)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

struct RecipeMetadataRow: View {
    let prepTime: Int
    let difficulty: Meal.Difficulty
    let cuisine: Meal.Cuisine
    
    private var formattedPrepTime: String {
        if prepTime < 60 {
            return "\(prepTime) min"
        } else {
            let hours = prepTime / 60
            let minutes = prepTime % 60
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
    }
    
    private var cuisineEmoji: String {
        switch cuisine {
        case .italian: return "🇮🇹"
        case .american: return "🇺🇸"
        case .asian: return "🥢"
        case .mediterranean: return "🫒"
        case .mexican: return "🌮"
        }
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Prep Time
            MetadataBadge(
                icon: "clock",
                text: formattedPrepTime,
                color: .blue
            )
            
            // Difficulty
            MetadataBadge(
                icon: "chart.bar",
                text: difficulty.rawValue,
                color: difficultyColor
            )
            
            // Cuisine
            MetadataBadge(
                icon: nil,
                text: "\(cuisineEmoji) \(cuisine.rawValue)",
                color: .purple
            )
            
            Spacer()
        }
    }
}

struct NutritionInfoRow: View {
    let nutrition: NutritionInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nutrition")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                // Calories (prominent)
                NutritionBadge(
                    value: "\(nutrition.calories ?? 0)",
                    unit: "cal",
                    label: "Calories",
                    color: .orange,
                    isProminent: true
                )
                
                // Macros
                NutritionBadge(
                    value: "\(nutrition.protein ?? 0)",
                    unit: "g",
                    label: "Protein",
                    color: .red,
                    isProminent: false
                )
                
                NutritionBadge(
                    value: "\(nutrition.carbs ?? 0)",
                    unit: "g",
                    label: "Carbs",
                    color: .green,
                    isProminent: false
                )
                
                NutritionBadge(
                    value: "\(nutrition.fat ?? 0)",
                    unit: "g",
                    label: "Fat",
                    color: .yellow,
                    isProminent: false
                )
                
                Spacer()
            }
        }
    }
}

struct DietTagsRow: View {
    let dietTags: [Meal.DietType]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Diet & Lifestyle")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100), spacing: 8)
            ], spacing: 8) {
                ForEach(dietTags, id: \.self) { tag in
                    DietTag(tag: tag)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct MetadataBadge: View {
    let icon: String?
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(color.opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct NutritionBadge: View {
    let value: String
    let unit: String
    let label: String
    let color: Color
    let isProminent: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(isProminent ? .title3 : .body)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: isProminent ? 60 : 45)
        .padding(.vertical, 8)
        .padding(.horizontal, isProminent ? 12 : 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct DietTag: View {
    let tag: Meal.DietType
    
    private var tagColor: Color {
        switch tag {
        case .vegetarian, .vegan:
            return .green
        case .glutenFree:
            return .orange
        case .dairyFree:
            return .blue
        case .lowCarb:
            return .purple
        case .highProtein:
            return .red
        case .paleo:
            return .brown
        case .lowSodium:
            return .cyan
        case .quickEasy:
            return .mint
        }
    }
    
    var body: some View {
        Text(tag.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(tagColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(tagColor.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(tagColor.opacity(0.3), lineWidth: 0.5)
            )
    }
}

// MARK: - Preview
struct NutritionBadges_Previews: PreviewProvider {
    static var previews: some View {
        let sampleNutrition = NutritionInfo(calories: 520, protein: 35, carbs: 28, fat: 24)
        let sampleDietTags: [Meal.DietType] = [.highProtein, .glutenFree, .quickEasy]
        
        ScrollView {
            VStack(spacing: 20) {
                NutritionBadges(
                    nutritionInfo: sampleNutrition,
                    dietTags: sampleDietTags,
                    prepTime: 45,
                    difficulty: .medium,
                    cuisine: .italian
                )
                
                NutritionBadges(
                    nutritionInfo: nil,
                    dietTags: [.vegetarian, .lowCarb],
                    prepTime: 15,
                    difficulty: .easy,
                    cuisine: .asian
                )
            }
        }
        .previewDisplayName("Nutrition Badges")
    }
}
