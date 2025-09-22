//
//  HomeView.swift
//  meal.advisor.ios
//
//  Scaffolding: Primary suggestion screen placeholder
//

import SwiftUI

struct HomeView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var favoritesService = FavoritesService.shared
    @State private var selectedMeal: Meal?
    @State private var showPremiumAlert = false
    @Environment(\.openURL) private var openURL
    
    init() {
        self._viewModel = StateObject(wrappedValue: HomeViewModel(appState: AppState.shared))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TimeGreeting(date: Date())

                Group {
                    if appState.isLoading {
                        VStack(alignment: .leading, spacing: 12) {
                            LoadingShimmer()
                                .aspectRatio(16/9, contentMode: .fit)
                            LoadingShimmer()
                                .frame(height: 16)
                                .cornerRadius(8)
                            LoadingShimmer()
                                .frame(width: 220, height: 16)
                                .cornerRadius(8)
                        }
                        .padding(16)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        .accessibilityLabel(String(localized: "loading_new_suggestion"))
                    } else if let error = appState.errorMessage {
                        // Error state in suggestion card area
                        VStack(spacing: 16) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.red)
                            
                            VStack(spacing: 8) {
                                Text("Unable to Load Suggestion")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button("Try Again") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    viewModel.retry()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.primaryOrange)
                        }
                        .padding(24)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        .accessibilityLabel("Error loading suggestion: \(error)")
                    } else if let meal = viewModel.meal {
                        SuggestionCard(
                            title: meal.title,
                            description: meal.description,
                            timeText: "\(meal.prepTime) min",
                            badges: [meal.difficulty.rawValue, meal.cuisine.rawValue],
                            imageURL: nil
                        )
                        .id(meal.id)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))

                        SuggestionActionsRow(
                            isSaved: favoritesService.isFavorite(meal),
                            onSeeRecipe: { selectedMeal = meal },
                            onToggleSave: { toggleFavorite(meal) },
                            onOrder: {
                                let query = meal.title
                                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "meal"
                                let url = URL(string: "https://www.ubereats.com/search?query=\(query)")!
                                openURL(url)
                            }
                        )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 220)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 36, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    Text(String(localized: "placeholder_suggestion"))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            )
                    }
                }

                PrimaryButton(title: primaryButtonTitle) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        viewModel.getNewSuggestion()
                    }
                }
                .disabled(appState.isLoading)

                // Note: Error state now handled in main suggestion card area above
            }
            .padding(.horizontal, 16)
            .navigationTitle(String(localized: "home"))
            // Note: Toast overlay removed - using main error state in suggestion card area
        }
        .fullScreenCover(item: $selectedMeal) { meal in
            RecipeDetailView(meal: meal)
        }
        .alert("Premium Required", isPresented: $showPremiumAlert) {
            Button("Upgrade to Premium") {
                // TODO: Show actual paywall
                print("🍽️ Show paywall from home")
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Save unlimited recipes to your favorites with Premium. Access them anytime, even offline!")
        }
    }
    
    // MARK: - Actions
    
    private func toggleFavorite(_ meal: Meal) {
        // Check premium status first
        guard appState.isPremium else {
            showPremiumAlert = true
            return
        }
        
        Task {
            do {
                try await favoritesService.toggleFavorite(meal)
                
                // Haptic feedback on successful save/unsave
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
            } catch {
                print("🍽️ [HomeView] Failed to toggle favorite: \(error)")
            }
        }
    }
}

private extension HomeView {
    var primaryButtonTitle: String {
        if appState.isLoading { return String(localized: "loading") }
        return viewModel.meal == nil ? String(localized: "get_new_suggestion") : String(localized: "show_another")
    }
}

#Preview {
    HomeView()
}
