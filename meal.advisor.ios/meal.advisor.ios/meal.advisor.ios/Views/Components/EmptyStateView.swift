//
//  EmptyStateView.swift
//  meal.advisor.ios
//
//  Reusable empty state component for consistent UI across the app
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            // Content
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Action Button (if provided)
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityLabel("\(actionTitle) for \(title)")
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }
}

// MARK: - Convenience Initializers

extension EmptyStateView {
    /// Empty state for when no content is available
    static func noContent(
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "tray",
            title: title,
            description: description,
            actionTitle: actionTitle,
            action: action
        )
    }
    
    /// Empty state for when no favorites are saved
    static func noFavorites(
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "heart.fill",
            title: "No Favorites Yet",
            description: "Heart recipes you love to save them here!",
            actionTitle: actionTitle,
            action: action
        )
    }
    
    /// Empty state for when no suggestions are available
    static func noSuggestions(
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "fork.knife",
            title: "Ready for a Suggestion?",
            description: "Tap the button below to get your personalized meal recommendation!",
            actionTitle: actionTitle,
            action: action
        )
    }
    
    /// Empty state for premium required features
    static func premiumRequired(
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "heart.circle",
            title: title,
            description: description,
            actionTitle: actionTitle,
            action: action
        )
    }
    
    /// Empty state for network errors
    static func networkError(
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.exclamationmark",
            title: "Connection Issue",
            description: "Check your internet connection and try again.",
            actionTitle: actionTitle,
            action: action
        )
    }
}

#Preview("No Content") {
    EmptyStateView.noContent(
        title: "No Results Found",
        description: "Try adjusting your search criteria or preferences.",
        actionTitle: "Try Again",
        action: {}
    )
}

#Preview("No Favorites") {
    EmptyStateView.noFavorites(
        actionTitle: "Browse Suggestions",
        action: {}
    )
}

#Preview("Premium Required") {
    EmptyStateView.premiumRequired(
        title: "Save Your Favorite Recipes",
        description: "Keep track of meals you love with Premium. Access them anytime, even offline!",
        actionTitle: "Upgrade to Premium",
        action: {}
    )
}
