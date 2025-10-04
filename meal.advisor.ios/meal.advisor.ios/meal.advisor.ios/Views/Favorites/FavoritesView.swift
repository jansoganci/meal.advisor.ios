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
    @StateObject private var authService = AuthService.shared
    @State private var showPaywall = false
    @State private var showSignInPrompt = false
    @State private var selectedMeal: Meal?
    @State private var searchText = ""
    @State private var selectedCuisine: Meal.Cuisine?
    @State private var selectedDiet: Meal.DietType?
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !authService.isAuthenticated {
                    // Sign in required state
                    EmptyStateView(
                        icon: "person.crop.circle.badge.exclamationmark",
                        title: "Sign In to Save Favorites",
                        description: "Sign in to save your favorite recipes and access them across all your devices.",
                        actionTitle: "Sign In",
                        action: {
                            showSignInPrompt = true
                        }
                    )
                } else if !appState.isPremium {
                    // Premium required state
                    EmptyStateView.premiumRequired(
                        title: "Save Your Favorite Recipes",
                        description: "Keep track of meals you love with Premium. Access them anytime, even offline!",
                        actionTitle: "Upgrade to Premium",
                        action: {
                            showPaywall = true
                        }
                    )
                } else if favoritesService.favorites.isEmpty {
                    // Empty favorites state (premium users)
                    EmptyStateView.noFavorites()
                } else if filteredFavorites.isEmpty {
                    // No results from search/filter
                    EmptyStateView.noContent(
                        title: "No Results Found",
                        description: "Try adjusting your search or filter criteria."
                    )
                } else {
                    // Grid layout for saved favorites
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(filteredFavorites) { meal in
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
            .searchable(text: $searchText, prompt: "Search favorites...")
            .toolbar(content: {
                if appState.isPremium && !favoritesService.favorites.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showFilters.toggle()
                        } label: {
                            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .foregroundColor(hasActiveFilters ? .accentColor : .secondary)
                        }
                        .accessibilityLabel("Filter favorites")
                    }
                }
            })
        }
        .fullScreenCover(item: $selectedMeal) { meal in
            RecipeDetailView(meal: meal)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(source: .favorites)
        }
        .sheet(isPresented: $showSignInPrompt) {
            SignInPromptView(context: .premiumFeature)
        }
        .sheet(isPresented: $showFilters) {
            FavoritesFilterSheet(
                selectedCuisine: $selectedCuisine,
                selectedDiet: $selectedDiet,
                onClearAll: {
                    selectedCuisine = nil
                    selectedDiet = nil
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredFavorites: [Meal] {
        var meals = favoritesService.favorites
        
        // Apply search filter
        if !searchText.isEmpty {
            meals = meals.filter { meal in
                meal.title.localizedCaseInsensitiveContains(searchText) ||
                meal.description.localizedCaseInsensitiveContains(searchText) ||
                meal.cuisine.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply cuisine filter
        if let cuisine = selectedCuisine {
            meals = meals.filter { $0.cuisine == cuisine }
        }
        
        // Apply diet filter
        if let diet = selectedDiet {
            meals = meals.filter { $0.dietTags.contains(diet) }
        }
        
        return meals
    }
    
    private var hasActiveFilters: Bool {
        selectedCuisine != nil || selectedDiet != nil
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
