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
                    VStack(spacing: 20) {
                        Image(systemName: "heart.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange.gradient)
                        
                        VStack(spacing: 8) {
                            Text("Save Your Favorite Recipes")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            
                            Text("Keep track of meals you love with Premium. Access them anytime, even offline!")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Upgrade to Premium") {
                            showPremiumAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(32)
                } else if favoritesService.favorites.isEmpty {
                    // Empty favorites state (premium users)
                    VStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No Favorites Yet")
                            .font(.headline)
                        Text("Heart recipes you love to save them here!")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
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
