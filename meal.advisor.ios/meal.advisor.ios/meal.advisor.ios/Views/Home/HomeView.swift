//
//  HomeView.swift
//  meal.advisor.ios
//
//  Scaffolding: Primary suggestion screen placeholder
//

import SwiftUI

struct HomeView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var mealService = MealService() // 🔧 FIX: Directly observe for proper SwiftUI reactivity
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var favoritesService = FavoritesService.shared
    @StateObject private var authService = AuthService.shared
    @StateObject private var usageTrackingService = UsageTrackingService.shared
    @State private var selectedMeal: Meal?
    @State private var showPremiumAlert = false
    @State private var showPaywall = false
    @State private var showSignInPrompt = false
    @State private var showDeliverySheet = false
    @State private var deliveryMealTitle: String = ""
    @State private var offlineStatus: (isOffline: Bool, hasOfflineContent: Bool) = (false, false)
    @Environment(\.openURL) private var openURL
    
    init() {
        let mealService = MealService()
        self._mealService = StateObject(wrappedValue: mealService)
        self._viewModel = StateObject(wrappedValue: HomeViewModel(appState: AppState.shared, mealService: mealService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TimeGreeting(date: Date())
                    .padding(.top, 8)
                
                // ✅ Usage Counter Badge (Free users only)
                if !appState.isPremium {
                    UsageCounterBadge(remaining: usageTrackingService.state.remainingCount)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Offline Status Banner
                if offlineStatus.isOffline {
                    OfflineBanner(
                        isOffline: offlineStatus.isOffline,
                        hasOfflineContent: offlineStatus.hasOfflineContent,
                        onRetry: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                viewModel.getNewSuggestion()
                            }
                        }
                    )
                }

                Group {
                    if mealService.state.isLoading {
                        VStack(spacing: 16) {
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
                            
                            Text("Generating meal...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
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
                    } else if let meal = mealService.state.currentSuggestion {
                        VStack(spacing: 8) {
                            SuggestionCard(
                                title: meal.title,
                                description: meal.description,
                                timeText: "\(meal.prepTime) min",
                                badges: [meal.difficulty.rawValue, meal.cuisine.rawValue],
                                imageURL: meal.imageURL
                            )
                            // 🔧 FIX: Use meal ID + imageURL for unique identity
                            // This forces RemoteImage to re-render when image URL changes
                            .id("\(meal.id)-\(meal.imageURL?.absoluteString ?? "no-image")")
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }

                        SuggestionActionsRow(
                            isSaved: favoritesService.isFavorite(meal),
                            onSeeRecipe: { selectedMeal = meal },
                            onToggleSave: { toggleFavorite(meal) },
                            onOrder: {
                                deliveryMealTitle = meal.title
                                showDeliverySheet = true
                            }
                        )
                        
                        // Meal Rating Section
                        MealRatingView(
                            rating: Binding(
                                get: { mealService.getRating(for: meal) },
                                set: { newRating in
                                    mealService.rateMeal(meal, rating: newRating ?? .none)
                                }
                            ),
                            onRatingChanged: { rating in
                                mealService.rateMeal(meal, rating: rating)
                            }
                        )
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 8) {
                                Text("No Suggestions Yet")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Tap the button below to get your first meal suggestion")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(24)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                }
                
                Spacer(minLength: 16)

                PrimaryButton(title: primaryButtonTitle) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        viewModel.getNewSuggestion()
                    }
                }
                .disabled(mealService.state.isLoading)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .navigationBarHidden(true)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CompactOfflineIndicator(
                        isOffline: offlineStatus.isOffline,
                        hasOfflineContent: offlineStatus.hasOfflineContent
                    )
                }
            })
            .task {
                // ⚡ PERFORMANCE: Fetch offline status asynchronously on view appear
                offlineStatus = await mealService.getOfflineStatus()
            }
        }
        .fullScreenCover(item: $selectedMeal) { meal in
            RecipeDetailView(meal: meal)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(source: .favorites)
        }
        .sheet(isPresented: $viewModel.showQuotaLimitPaywall) {
            PaywallView(source: .suggestionLimit)
        }
        .sheet(isPresented: $showSignInPrompt) {
            SignInPromptView(context: .savingFavorite)
        }
        .sheet(isPresented: $showDeliverySheet) {
            DeliveryAppSheet(mealTitle: deliveryMealTitle) { app in
                if let url = app.searchURL(for: deliveryMealTitle) {
                    openURL(url)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleFavorite(_ meal: Meal) {
        // Check authentication first
        guard authService.isAuthenticated else {
            showSignInPrompt = true
            return
        }
        
        // Then check premium status
        guard appState.isPremium else {
            showPaywall = true
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
        if mealService.state.isLoading { return String(localized: "loading") }
        return mealService.state.currentSuggestion == nil ? String(localized: "get_new_suggestion") : String(localized: "show_another")
    }
}

#Preview {
    HomeView()
}
