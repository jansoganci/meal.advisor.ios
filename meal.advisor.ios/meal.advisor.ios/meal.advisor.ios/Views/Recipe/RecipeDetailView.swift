//
//  RecipeDetailView.swift
//  meal.advisor.ios
//
//  Beautiful, clean recipe detail screen using modern components
//

import SwiftUI

struct RecipeDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecipeViewModel
    @StateObject private var favoritesService = FavoritesService.shared
    @StateObject private var appState = AppState.shared
    @StateObject private var authService = AuthService.shared
    @State private var showPremiumAlert = false
    @State private var showSignInPrompt = false
    
    init(meal: Meal) {
        self.meal = meal
        self._viewModel = StateObject(wrappedValue: RecipeViewModel(meal: meal))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // Hero Image Section
                    HeroImageSection(
                        imageURL: meal.imageURL,
                        title: meal.title,
                        description: meal.description
                    )
                    
                    // Recipe Metadata & Nutrition
                    NutritionBadges(
                        nutritionInfo: meal.nutritionInfo,
                        dietTags: meal.dietTags,
                        prepTime: meal.prepTime,
                        difficulty: meal.difficulty,
                        cuisine: meal.cuisine
                    )
                    
                    // Divider
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Ingredients Section
                    IngredientsList(ingredients: meal.ingredients)
                    
                    // Divider
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Instructions Section
                    InstructionsView(instructions: meal.instructions)
                    
                    // Bottom spacing for comfortable scrolling
                    Spacer()
                        .frame(height: 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                            Text("Close")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Share Button
                        Button(action: shareRecipe) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        // Save Button
                        Button(action: toggleSaved) {
                            Image(systemName: favoritesService.isFavorite(meal) ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(favoritesService.isFavorite(meal) ? .red : .primary)
                        }
                    }
                }
            })
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .alert("Premium Required", isPresented: $showPremiumAlert) {
                Button("Upgrade to Premium") {
                    // TODO: Show actual paywall
                    print("🍽️ Show paywall from recipe detail")
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Save unlimited recipes to your favorites with Premium. Access them anytime, even offline!")
            }
            .sheet(isPresented: $showSignInPrompt) {
                SignInPromptView(context: .savingFavorite)
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleSaved() {
        // Check authentication first
        guard authService.isAuthenticated else {
            showSignInPrompt = true
            return
        }
        
        // Then check premium status
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
                
                // Animation feedback
                withAnimation(.easeInOut(duration: 0.2)) {
                    // The UI will update automatically via @Published favorites
                }
                
            } catch {
                print("🍽️ [RecipeDetailView] Failed to toggle favorite: \(error)")
                // Could show error alert here if needed
            }
        }
    }

    private func shareRecipe() {
        let shareText = viewModel.shareRecipe()
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}

// MARK: - Hero Image Section

struct HeroImageSection: View {
    let imageURL: URL?
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero Image
            RemoteImage(url: imageURL)
                .aspectRatio(16/9, contentMode: .fill)
                .clipped()
                .accessibilityLabel("Photo of \(title)")
            
            // Title and Description
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMeal = Meal(
            id: UUID(),
            title: "Chicken Parmesan",
            description: "Golden-breaded chicken cutlets topped with marinara sauce and melted mozzarella cheese, baked to perfection.",
            prepTime: 45,
            difficulty: .medium,
            cuisine: .italian,
            dietTags: [.highProtein],
            imageURL: nil,
            ingredients: [
                Ingredient(name: "Chicken breasts", amount: "2", unit: "large"),
                Ingredient(name: "Panko breadcrumbs", amount: "1", unit: "cup"),
                Ingredient(name: "Parmesan cheese", amount: "1/2", unit: "cup")
            ],
            instructions: [
                "Pound chicken to 1/2 inch thickness and season with salt and pepper",
                "Set up breading station with flour, beaten eggs, and breadcrumb mixture",
                "Bread chicken by dipping in flour, eggs, then breadcrumbs"
            ],
            nutritionInfo: NutritionInfo(calories: 520, protein: 45, carbs: 22, fat: 28)
        )
        
        RecipeDetailView(meal: sampleMeal)
            .previewDisplayName("Recipe Detail")
    }
}