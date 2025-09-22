//
//  SuggestionCard.swift
//  meal.advisor.ios
//
//  Visual card showing the current meal suggestion.
//

import SwiftUI

struct SuggestionCard: View {
    let title: String
    let description: String
    let timeText: String
    let badges: [String] // e.g., ["Easy", "Italian"]
    let imageURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RemoteImage(url: imageURL)
                .accessibilityLabel("Photo of \(title)")
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(title)
                .font(.mealTitle)
                .foregroundColor(.primaryText)
                .lineLimit(2)

            HStack(spacing: 8) {
                Badge(text: timeText)
                ForEach(badges.prefix(2), id: \.self) { text in
                    Badge(text: text)
                }
            }

            Text(description)
                .font(.bodyText)
                .foregroundColor(.secondaryText)
                .lineLimit(2)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Meal suggestion: \(title), \(timeText)")
    }
}

private struct Badge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundColor(.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
    }
}

#Preview {
    SuggestionCard(
        title: "Creamy Tuscan Chicken",
        description: "Rich, cozy weeknight dinner with sun-dried tomatoes and spinach.",
        timeText: "25 min",
        badges: ["Easy", "Italian"],
        imageURL: nil
    )
    .padding()
}
