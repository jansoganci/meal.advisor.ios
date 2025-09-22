//
//  FavoriteMealCard.swift
//  meal.advisor.ios
//
//  Compact card for displaying favorite meals in grid layout
//

import SwiftUI

struct FavoriteMealCard: View {
    let meal: Meal
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image with overlay heart button
            ZStack(alignment: .topTrailing) {
                if let imageURL = meal.imageURL {
                    RemoteImage(url: imageURL)
                        .aspectRatio(4/3, contentMode: .fill)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    // Fallback placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .aspectRatio(4/3, contentMode: .fit)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                }
                
                // Remove button
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 28, height: 28)
                        )
                }
                .padding(8)
            }
            
            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    // Prep time
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(meal.prepTime)m")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    // Difficulty
                    HStack(spacing: 3) {
                        Image(systemName: meal.difficulty.iconName)
                            .font(.caption2)
                        Text(meal.difficulty.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(meal.difficulty.color)
                    
                    Spacer()
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Extensions for UI
extension Meal.Difficulty {
    var iconName: String {
        switch self {
        case .easy: return "leaf"
        case .medium: return "flame"
        case .hard: return "bolt"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Preview
struct FavoriteMealCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMeal = Meal(
            id: UUID(),
            title: "Creamy Garlic Chicken Pasta",
            description: "Rich and creamy pasta dish with tender chicken and aromatic garlic.",
            prepTime: 25,
            difficulty: .medium,
            cuisine: .italian,
            dietTags: [.highProtein],
            imageURL: URL(string: "https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400"),
            ingredients: [],
            instructions: [],
            nutritionInfo: nil
        )
        
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            FavoriteMealCard(
                meal: sampleMeal,
                onTap: { print("Tapped meal") },
                onRemove: { print("Remove meal") }
            )
            
            FavoriteMealCard(
                meal: sampleMeal,
                onTap: { print("Tapped meal") },
                onRemove: { print("Remove meal") }
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
