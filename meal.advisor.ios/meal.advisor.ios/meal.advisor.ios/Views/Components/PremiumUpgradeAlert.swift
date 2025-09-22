//
//  PremiumUpgradeAlert.swift
//  meal.advisor.ios
//
//  Simple alert for premium upgrade when accessing gated features
//

import SwiftUI

struct PremiumUpgradeAlert {
    static func create(
        title: String = "Premium Feature",
        message: String = "This feature requires a Premium subscription to unlock unlimited access.",
        upgradeAction: @escaping () -> Void = {}
    ) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(Text("Upgrade to Premium")) {
                upgradeAction()
            },
            secondaryButton: .cancel(Text("Maybe Later"))
        )
    }
    
    // Specific alert for favorites
    static func favoritesAlert(upgradeAction: @escaping () -> Void = {}) -> Alert {
        create(
            title: "Save to Favorites",
            message: "Save unlimited recipes to your favorites with Premium. Access them anytime, even offline!",
            upgradeAction: upgradeAction
        )
    }
    
    // Specific alert for favorites view access
    static func favoritesViewAlert(upgradeAction: @escaping () -> Void = {}) -> Alert {
        create(
            title: "Favorites",
            message: "View and organize your saved recipes with Premium. Never lose track of meals you love!",
            upgradeAction: upgradeAction
        )
    }
}
