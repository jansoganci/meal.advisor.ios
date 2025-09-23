//
//  FavoritesView.swift
//  meal.advisor.ios
//
//  Scaffolding: Favorites screen placeholder
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var favoritesService = FavoritesService.shared
    @State private var showPremiumAlert = false
    @State private var selectedMeal: Meal?
    
    var body: some View {
        NavigationStack {
            Group {
                if !appState.isPremium {
                    // Premium required state
                    EmptyStateView.premiumRequired(
                        title: "Save Your Favorite Recipes",
                        description: "Keep track of meals you love with Premium. Access them anytime, even offline!",
                        actionTitle: "Upgrade to Premium",
                        action: {
                            showPremiumAlert = true
                        }
                    )
                } else if favoritesService.favorites.isEmpty {
                    // Empty favorites state (premium users)
                    EmptyStateView.noFavorites()
                } else {
                    // Grid layout for saved favorites
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(favoritesService.favorites) { meal in
                                FavoriteMealCard(
                                    meal: meal,
                                    onTap: {
                                        selectedMeal = meal
                                    },
                                    onRemove: {
                                        removeFavorite(meal)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("Favorites")
            .alert("Premium Required", isPresented: $showPremiumAlert) {
                Button("Upgrade") {
                    // TODO: Show actual paywall
                    print("🍽️ Show paywall")
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Favorites require a Premium subscription. Upgrade to save unlimited recipes!")
            }
        }
        .fullScreenCover(item: $selectedMeal) { meal in
            RecipeDetailView(meal: meal)
        }
    }
    
    // MARK: - Actions
    
    private func removeFavorite(_ meal: Meal) {
        Task {
            do {
                try await favoritesService.removeFavorite(meal)
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
            } catch {
                print("🍽️ [FavoritesView] Failed to remove favorite: \(error)")
            }
        }
    }
}

#Preview {
    FavoritesView()
}
