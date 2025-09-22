//
//  HomeView.swift
//  meal.advisor.ios
//
//  Scaffolding: Primary suggestion screen placeholder
//

import SwiftUI

struct HomeView: View {
    @StateObject private var appState = AppState()
    @StateObject private var viewModel: HomeViewModel
    @State private var isSaved = false
    @State private var selectedMeal: Meal?
    @Environment(\.openURL) private var openURL
    
    init() {
        let appState = AppState()
        self._appState = StateObject(wrappedValue: appState)
        self._viewModel = StateObject(wrappedValue: HomeViewModel(appState: appState))
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
                            isSaved: isSaved,
                            onSeeRecipe: { selectedMeal = meal },
                            onToggleSave: { isSaved.toggle() },
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
