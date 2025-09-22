# MealAdvisor SwiftUI Project Structure

*Last Updated: September 21, 2025*  
*Project: MealAdvisor iOS App - "What Should I Eat Today?" Utility*

---

## 📱 **Xcode Project Organization**

### Root Project Structure
```
MealAdvisor.xcodeproj
├── MealAdvisor/
│   ├── App/
│   │   ├── MealAdvisorApp.swift          // App entry point
│   │   ├── ContentView.swift             // Root view container
│   │   └── AppDelegate.swift             // iOS lifecycle handling
│   │
│   ├── Views/
│   │   ├── Home/
│   │   │   ├── HomeView.swift            // Main suggestion screen
│   │   │   ├── HomeViewModel.swift       // Business logic
│   │   │   └── Components/
│   │   │       ├── SuggestionCard.swift  // Hero meal card
│   │   │       ├── LoadingShimmer.swift  // Skeleton loading
│   │   │       └── TimeGreeting.swift    // "Good morning!" text
│   │   │
│   │   ├── Recipe/
│   │   │   ├── RecipeDetailView.swift    // Full recipe modal
│   │   │   ├── RecipeViewModel.swift     // Recipe data handling
│   │   │   └── Components/
│   │   │       ├── IngredientsList.swift // Recipe ingredients
│   │   │       ├── InstructionsView.swift // Step-by-step
│   │   │       └── NutritionBadges.swift // Time, difficulty, etc.
│   │   │
│   │   ├── Favorites/
│   │   │   ├── FavoritesView.swift       // Saved meals grid
│   │   │   ├── FavoritesViewModel.swift  // Premium feature logic
│   │   │   └── Components/
│   │   │       ├── FavoriteCard.swift    // Grid item card
│   │   │       └── EmptyFavorites.swift  // No favorites state
│   │   │
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift        // Main settings screen
│   │   │   ├── SettingsViewModel.swift   // User preferences
│   │   │   ├── DietaryRestrictionsView.swift // Diet setup
│   │   │   ├── CookingTimeView.swift     // Time preferences
│   │   │   └── Components/
│   │   │       ├── SettingsRow.swift     // List row component
│   │   │       └── PreferenceToggle.swift // Toggle switches
│   │   │
│   │   ├── Premium/
│   │   │   ├── PaywallView.swift         // Premium upgrade modal
│   │   │   ├── PaywallViewModel.swift    // StoreKit handling
│   │   │   └── Components/
│   │   │       ├── FeaturesList.swift    // Premium benefits
│   │   │       └── PricingCard.swift     // Subscription options
│   │   │
│   │   └── Components/                   // Shared across screens
│   │       ├── CustomButton.swift        // Brand-styled buttons
│   │       ├── ErrorView.swift           // Error states
│   │       ├── LoadingView.swift         // Loading indicators
│   │       ├── ToastView.swift           // Bottom toast notifications
│   │       └── TabBarView.swift          // Custom tab bar
│   │
│   ├── Models/
│   │   ├── Meal.swift                    // Core meal data structure
│   │   ├── User.swift                    // User profile model
│   │   ├── UserPreferences.swift         // Diet/time preferences
│   │   ├── Favorite.swift                // Saved meal model
│   │   └── AppState.swift                // Global app state
│   │
│   ├── Services/
│   │   ├── NetworkService.swift          // Supabase wrapper
│   │   ├── AuthService.swift             // Sign in with Apple
│   │   ├── MealService.swift             // Meal suggestions API
│   │   ├── FavoritesService.swift        // Premium favorites
│   │   ├── UserPreferencesService.swift  // Settings persistence
│   │   ├── ImageService.swift            // Unsplash integration
│   │   ├── PurchaseService.swift         // StoreKit 2 handling
│   │   ├── NotificationService.swift     // Push notifications
│   │   └── AnalyticsService.swift        // Usage tracking
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── Color+Extensions.swift    // Brand colors
│   │   │   ├── Font+Extensions.swift     // Typography scale
│   │   │   ├── View+Extensions.swift     // SwiftUI helpers
│   │   │   └── String+Extensions.swift   // Text utilities
│   │   │
│   │   ├── Constants.swift               // App-wide constants
│   │   ├── Haptics.swift                 // Haptic feedback
│   │   ├── ImageCache.swift              // Image caching logic
│   │   └── KeychainHelper.swift          // Secure storage
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   │   ├── Colors/
│   │   │   │   ├── PrimaryOrange.colorset
│   │   │   │   └── AccentGreen.colorset
│   │   │   ├── Images/
│   │   │   │   └── AppIcon.appiconset
│   │   │   └── Icons/                    // SF Symbols references
│   │   │
│   │   ├── Localizable.strings           // Text localization
│   │   ├── Info.plist                    // App configuration
│   │   └── MealAdvisor.entitlements      // App capabilities
│   │
│   └── Preview Content/
│       └── Preview Assets.xcassets       // Development assets
│
├── MealAdvisorTests/
│   ├── ViewModelTests/
│   │   ├── HomeViewModelTests.swift
│   │   ├── FavoritesViewModelTests.swift
│   │   └── SettingsViewModelTests.swift
│   │
│   ├── ServiceTests/
│   │   ├── MealServiceTests.swift
│   │   ├── AuthServiceTests.swift
│   │   └── PurchaseServiceTests.swift
│   │
│   └── ModelTests/
│       ├── MealTests.swift
│       └── UserPreferencesTests.swift
│
└── MealAdvisorUITests/
    ├── HomeFlowTests.swift
    ├── PremiumFlowTests.swift
    └── NavigationTests.swift
```

---

## 🏗️ **Architecture Implementation**

### MVVM Pattern Structure
```swift
// Example: HomeView + HomeViewModel pattern
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        // UI implementation
    }
}

class HomeViewModel: ObservableObject {
    @Published var currentMeal: Meal?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let mealService = MealService()
    
    func loadNewSuggestion() async {
        // Business logic
    }
}
```

### Service Layer Pattern
```swift
// NetworkService.swift - Supabase wrapper
class NetworkService {
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )
    
    func fetchMealSuggestion(preferences: UserPreferences) async throws -> Meal {
        // API call implementation
    }
}

// MealService.swift - Domain-specific service
class MealService {
    private let networkService = NetworkService()
    
    func getSuggestion(for preferences: UserPreferences) async throws -> Meal {
        // Business logic + network call
    }
}
```

---

## 📱 **Core App Structure**

### App Entry Point
```swift
// MealAdvisorApp.swift
@main
struct MealAdvisorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    configureApp()
                }
        }
    }
    
    private func configureApp() {
        // Setup analytics, notifications, etc.
    }
}
```

### Root Content View
```swift
// ContentView.swift - Tab bar container
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(Tab.home)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(Tab.favorites)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(Tab.settings)
        }
        .accentColor(Color("PrimaryOrange"))
    }
}
```

---

## 🎨 **Design System Implementation**

### Color System
```swift
// Color+Extensions.swift
extension Color {
    static let primaryOrange = Color("PrimaryOrange")
    static let accentGreen = Color("AccentGreen")
    
    // Semantic colors (auto dark mode)
    static let cardBackground = Color(.systemBackground)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
}
```

### Typography System
```swift
// Font+Extensions.swift
extension Font {
    static let mealTitle = Font.title2.bold()           // 22pt
    static let sectionHeader = Font.title.bold()        // 28pt
    static let bodyText = Font.body                     // 17pt
    static let metadata = Font.caption.weight(.medium)  // 12pt
}
```

### Component Styling
```swift
// CustomButton.swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.primaryOrange)
            .foregroundColor(.white)
            .font(.body.weight(.medium))
            .cornerRadius(12)
    }
}
```

---

## 📊 **Data Models Structure**

### Core Meal Model
```swift
// Meal.swift
struct Meal: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let prepTime: Int              // minutes
    let difficulty: Difficulty
    let cuisine: Cuisine
    let dietTags: [DietType]
    let imageURL: URL?
    let ingredients: [Ingredient]
    let instructions: [String]
    let nutritionInfo: NutritionInfo?
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
    
    enum Cuisine: String, CaseIterable, Codable {
        case italian = "Italian"
        case american = "American"
        case asian = "Asian"
        case mediterranean = "Mediterranean"
        case mexican = "Mexican"
    }
    
    enum DietType: String, CaseIterable, Codable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case lowCarb = "Low-Carb"
        case highProtein = "High-Protein"
        case paleo = "Paleo"
        case lowSodium = "Low-Sodium"
        case quickEasy = "Quick & Easy"
    }
}

struct Ingredient: Identifiable, Codable {
    let id: UUID
    let name: String
    let amount: String
    let unit: String?
}

struct NutritionInfo: Codable {
    let calories: Int?
    let protein: Int?    // grams
    let carbs: Int?      // grams
    let fat: Int?        // grams
}
```

### User Preferences Model
```swift
// UserPreferences.swift
struct UserPreferences: Codable {
    var dietaryRestrictions: Set<Meal.DietType>
    var cuisinePreferences: Set<Meal.Cuisine>
    var maxCookingTime: Int                    // minutes
    var difficultyPreference: Meal.Difficulty?
    var excludedIngredients: Set<String>
    
    static let `default` = UserPreferences(
        dietaryRestrictions: [],
        cuisinePreferences: Set(Meal.Cuisine.allCases),
        maxCookingTime: 60,
        difficultyPreference: nil,
        excludedIngredients: []
    )
}
```

### App State Management
```swift
// AppState.swift
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var currentUser: User?
    @Published var userPreferences = UserPreferences.default
    @Published var isPremium = false
    @Published var showPaywall = false
    
    enum Tab {
        case home, favorites, settings
    }
}
```

---

## 🔧 **Service Implementation Structure**

### Meal Service (Core Business Logic)
```swift
// MealService.swift
class MealService: ObservableObject {
    private let networkService = NetworkService()
    private let imageService = ImageService()
    
    @Published var currentSuggestion: Meal?
    @Published var isLoading = false
    
    func generateSuggestion(preferences: UserPreferences) async throws -> Meal {
        isLoading = true
        defer { isLoading = false }
        
        // 1. Fetch meal from Supabase based on preferences
        let meal = try await networkService.fetchMealSuggestion(preferences: preferences)
        
        // 2. Ensure image is cached for smooth display
        await imageService.preloadImage(url: meal.imageURL)
        
        // 3. Update current suggestion
        await MainActor.run {
            self.currentSuggestion = meal
        }
        
        return meal
    }
    
    func getRecipeDetails(for meal: Meal) async throws -> Meal {
        // Fetch full recipe details if not already loaded
        return try await networkService.fetchRecipeDetails(mealId: meal.id)
    }
}
```

### Premium Features Service
```swift
// FavoritesService.swift
class FavoritesService: ObservableObject {
    private let networkService = NetworkService()
    @Published var favorites: [Meal] = []
    
    func addToFavorites(_ meal: Meal) async throws {
        guard AppState.shared.isPremium else {
            throw FavoritesError.premiumRequired
        }
        
        try await networkService.saveFavorite(meal)
        await MainActor.run {
            favorites.append(meal)
        }
    }
    
    func removeFavorite(_ meal: Meal) async throws {
        try await networkService.removeFavorite(meal.id)
        await MainActor.run {
            favorites.removeAll { $0.id == meal.id }
        }
    }
    
    enum FavoritesError: Error {
        case premiumRequired
    }
}
```

### Purchase Service (StoreKit 2)
```swift
// PurchaseService.swift
import StoreKit

class PurchaseService: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchaseState: PurchaseState = .idle
    
    private let productIDs = [
        "com.mealadvisor.premium.monthly",
        "com.mealadvisor.premium.yearly"
    ]
    
    enum PurchaseState {
        case idle, purchasing, purchased, failed(Error)
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    purchaseState = .purchased
                    // Update user premium status
                }
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error)
        }
    }
}
```

---

## 🎯 **Key Implementation Patterns**

### Error Handling Strategy
```swift
// ErrorView.swift - Consistent error display
struct ErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: error.icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(error.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(error.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                PrimaryButton(title: "Try Again", action: retryAction)
                    .frame(maxWidth: 200)
            }
        }
        .padding()
    }
}

enum AppError: LocalizedError {
    case networkError
    case noSuggestions
    case premiumRequired
    
    var title: String {
        switch self {
        case .networkError: return "Connection Error"
        case .noSuggestions: return "No Suggestions Found"
        case .premiumRequired: return "Premium Required"
        }
    }
    
    var message: String {
        switch self {
        case .networkError: return "Please check your internet connection and try again."
        case .noSuggestions: return "We couldn't find any meals matching your preferences."
        case .premiumRequired: return "This feature is available with Premium subscription."
        }
    }
    
    var icon: String {
        switch self {
        case .networkError: return "wifi.slash"
        case .noSuggestions: return "fork.knife"
        case .premiumRequired: return "star.fill"
        }
    }
}
```

### Loading States Pattern
```swift
// LoadingShimmer.swift - Skeleton loading
struct LoadingShimmer: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray5))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 300 : -300)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
```

### Analytics Integration
```swift
// AnalyticsService.swift - Privacy-first tracking
class AnalyticsService {
    static let shared = AnalyticsService()
    
    func track(event: AnalyticsEvent) {
        // Only track essential app improvement metrics
        // No personal data, no user profiling
        
        switch event {
        case .suggestionGenerated:
            // Track suggestion success rate
            break
        case .recipeViewed(let cuisine):
            // Track popular cuisines
            break
        case .premiumUpgrade:
            // Track conversion metrics
            break
        }
    }
    
    enum AnalyticsEvent {
        case suggestionGenerated
        case recipeViewed(cuisine: Meal.Cuisine)
        case premiumUpgrade
        case appLaunched
        case errorOccurred(type: String)
    }
}
```

---

## 🚀 **Development Workflow**

### Phase 1: Core Foundation (Week 1)
1. **Setup project structure** with all folders and base files
2. **Implement basic navigation** (TabView + placeholder screens)
3. **Create design system** (colors, fonts, button styles)
4. **Setup Supabase connection** and basic meal model
5. **Build suggestion card component** with loading states

### Phase 2: Core Features (Week 2)
1. **Implement meal suggestion flow** (HomeView + HomeViewModel)
2. **Add recipe detail modal** with full recipe display
3. **Create settings screen** with basic preferences
4. **Setup image loading** with Unsplash integration
5. **Add error handling** and offline states

### Phase 3: Premium Features (Week 3)
1. **Implement favorites system** (grid view + empty states)
2. **Add StoreKit 2 integration** for subscriptions
3. **Create paywall modal** with pricing display
4. **Setup user authentication** (Sign in with Apple)
5. **Add premium feature gating**

### Phase 4: Polish & Testing (Week 4)
1. **Implement push notifications** for meal reminders
2. **Add haptic feedback** and micro-interactions
3. **Complete accessibility support** (VoiceOver, Dynamic Type)
4. **Write unit tests** for ViewModels and Services
5. **TestFlight deployment** and user feedback

---

## ✅ **Implementation Checklist**

### Project Setup
- [ ] Create Xcode project with SwiftUI + iOS 16+ target
- [ ] Setup folder structure according to this document
- [ ] Add Supabase Swift SDK via Swift Package Manager
- [ ] Configure color assets (PrimaryOrange, AccentGreen)
- [ ] Setup Info.plist with required permissions

### Core Implementation
- [ ] Implement MVVM architecture with @StateObject patterns
- [ ] Create reusable components (buttons, cards, loading states)
- [ ] Setup service layer with proper error handling
- [ ] Implement navigation flow (TabView + modal presentations)
- [ ] Add comprehensive error states with recovery actions

### Premium Integration
- [ ] Configure StoreKit 2 with product IDs
- [ ] Implement subscription validation and receipt checking
- [ ] Add premium feature gating throughout app
- [ ] Create paywall with clear value proposition
- [ ] Setup analytics for conversion tracking

### Quality Assurance
- [ ] Test all user flows on device
- [ ] Verify dark mode compatibility
- [ ] Check accessibility with VoiceOver
- [ ] Performance test with slow network conditions
- [ ] Memory leak testing with Instruments

---

**This project structure embodies the iPhone 5s philosophy: clean organization, predictable patterns, and every file serving a clear purpose. Follow this structure and you'll build a maintainable, scalable app that can evolve without becoming complex.** 📱✨

**Ready to start coding!** 🚀
