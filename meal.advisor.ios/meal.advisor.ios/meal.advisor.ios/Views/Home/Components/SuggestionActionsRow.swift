//
//  SuggestionActionsRow.swift
//  meal.advisor.ios
//
//  Secondary actions for a meal suggestion: See Recipe, Save, Order.
//

import SwiftUI

struct SuggestionActionsRow: View {
    let isSaved: Bool
    let onSeeRecipe: () -> Void
    let onToggleSave: () -> Void
    let onOrder: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // See Recipe - outlined secondary button
            Button(action: onSeeRecipe) {
                Text(String(localized: "see_recipe"))
                    .font(.callout.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.primaryOrange)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryOrange, lineWidth: 1.5)
                    )
                    .accessibilityLabel("See Recipe")
            }
            .buttonStyle(.plain)

            // Save - heart icon text button
            Button(action: onToggleSave) {
                HStack(spacing: 6) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                    Text(String(localized: "save"))
                }
                .font(.body.weight(.medium))
                .foregroundColor(.primaryOrange)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(isSaved ? "Saved to favorites" : "Save to favorites")
                .accessibilityHint("Premium feature in future")
            }
            .buttonStyle(.plain)

            // Order - deep link to delivery search (web fallback)
            Button(action: onOrder) {
                HStack(spacing: 6) {
                    Image(systemName: "bag")
                    Text(String(localized: "order"))
                }
                .font(.body.weight(.medium))
                .foregroundColor(.primaryOrange)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Find delivery options")
                .accessibilityHint("Opens delivery app search in browser")
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SuggestionActionsRow(
        isSaved: false,
        onSeeRecipe: {},
        onToggleSave: {},
        onOrder: {}
    )
    .padding()
}
