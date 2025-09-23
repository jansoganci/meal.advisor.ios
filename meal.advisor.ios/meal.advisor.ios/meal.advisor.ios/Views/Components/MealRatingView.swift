//
//  MealRatingView.swift
//  meal.advisor.ios
//
//  Meal rating component with thumbs up/down functionality
//

import SwiftUI

struct MealRatingView: View {
    @Binding var rating: MealRating?
    let onRatingChanged: ((MealRating) -> Void)?
    
    init(rating: Binding<MealRating?>, onRatingChanged: ((MealRating) -> Void)? = nil) {
        self._rating = rating
        self.onRatingChanged = onRatingChanged
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbs Down Button
            Button(action: {
                let newRating: MealRating = rating == .disliked ? .none : .disliked
                rating = newRating
                onRatingChanged?(newRating)
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                Image(systemName: rating == .disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.title2)
                    .foregroundColor(rating == .disliked ? .red : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Dislike this meal")
            .accessibilityValue(rating == .disliked ? "Disliked" : "Not disliked")
            
            // Rating Text
            Text(ratingText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            // Thumbs Up Button
            Button(action: {
                let newRating: MealRating = rating == .liked ? .none : .liked
                rating = newRating
                onRatingChanged?(newRating)
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                Image(systemName: rating == .liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.title2)
                    .foregroundColor(rating == .liked ? .green : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Like this meal")
            .accessibilityValue(rating == .liked ? "Liked" : "Not liked")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Meal rating: \(ratingText)")
    }
    
    private var ratingText: String {
        switch rating {
        case nil:
            return "Rate this meal"
        case .some(.liked):
            return "You liked this meal!"
        case .some(.disliked):
            return "You disliked this meal"
        case .some(.none):
            return "Rate this meal"
        }
    }
}

// MARK: - MealRating Enum

enum MealRating: String, CaseIterable, Codable {
    case none = "none"
    case liked = "liked"
    case disliked = "disliked"
    
    var displayText: String {
        switch self {
        case .none:
            return "No rating"
        case .liked:
            return "Liked"
        case .disliked:
            return "Disliked"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none:
            return "questionmark.circle"
        case .liked:
            return "hand.thumbsup.fill"
        case .disliked:
            return "hand.thumbsdown.fill"
        }
    }
}

// MARK: - Compact Rating View

struct CompactMealRatingView: View {
    let rating: MealRating?
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: rating?.systemImage ?? "questionmark.circle")
                .font(.caption)
                .foregroundColor(rating == .liked ? .green : rating == .disliked ? .red : .secondary)
            
            Text(rating?.displayText ?? "Not rated")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityLabel("Rating: \(rating?.displayText ?? "Not rated")")
    }
}

#Preview("No Rating") {
    MealRatingView(rating: .constant(nil))
        .padding()
}

#Preview("Liked") {
    MealRatingView(rating: .constant(.liked))
        .padding()
}

#Preview("Disliked") {
    MealRatingView(rating: .constant(.disliked))
        .padding()
}

#Preview("Compact Views") {
    VStack(spacing: 8) {
        CompactMealRatingView(rating: nil)
        CompactMealRatingView(rating: .liked)
        CompactMealRatingView(rating: .disliked)
    }
    .padding()
}
