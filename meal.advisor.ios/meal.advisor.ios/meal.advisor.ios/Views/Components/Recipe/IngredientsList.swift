//
//  IngredientsList.swift
//  meal.advisor.ios
//
//  Clean, minimal ingredients list component for recipe details
//

import SwiftUI

struct IngredientsList: View {
    let ingredients: [Ingredient]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(ingredients.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
            
            // Ingredients List
            VStack(spacing: 12) {
                ForEach(ingredients, id: \.id) { ingredient in
                    IngredientRow(ingredient: ingredient)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Amount + Unit
            HStack(spacing: 2) {
                Text(ingredient.amount)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(ingredient.unit)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(minWidth: 60, alignment: .leading)
            
            // Ingredient Name
            Text(ingredient.name)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview
struct IngredientsList_Previews: PreviewProvider {
    static var previews: some View {
        let sampleIngredients = [
            Ingredient(name: "Chicken breasts", amount: "2", unit: "large"),
            Ingredient(name: "Olive oil", amount: "2", unit: "tbsp"),
            Ingredient(name: "Garlic", amount: "3", unit: "cloves"),
            Ingredient(name: "Fresh basil", amount: "1/4", unit: "cup"),
            Ingredient(name: "Parmesan cheese", amount: "1/2", unit: "cup")
        ]
        
        IngredientsList(ingredients: sampleIngredients)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Ingredients List")
        
        IngredientRow(ingredient: Ingredient(name: "Chicken breast", amount: "1", unit: "lb"))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Single Ingredient")
    }
}
