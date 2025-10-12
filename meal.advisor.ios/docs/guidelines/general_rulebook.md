# MealAdvisor General Development Rulebook

*Last Updated: September 21, 2025*  
*Project: MealAdvisor iOS App - "What Should I Eat Today?" Utility*

---

## 🎯 **Development Philosophy**

### MVP-First Mindset
- **Ship fast, iterate faster** - Working iOS app > perfect architecture
- **User feedback > theoretical optimization** - Real users drive decisions
- **Business value > technical debt** - Solve real problems, optimize later
- **500 Line Rule** - Split files when they exceed 500 lines for maintainability

### iOS-Native Excellence
- Follow Apple Human Interface Guidelines (HIG) religiously
- Use native iOS patterns and feel - users should feel "at home"
- Leverage iOS-specific features (haptics, widgets, Siri shortcuts)
- Performance budgets: P95 suggestion < 3s, cold start < 2s

---

## 🏗️ **Architecture Standards**

### Code Organization (Hybrid Approach)
```
Views/
├── Home/
│   ├── HomeView.swift (main view, <500 lines)
│   ├── HomeViewModel.swift (business logic)
│   └── Components/
│       ├── SuggestionCard.swift (if used only in Home)
│       └── LoadingShimmer.swift (if used only in Home)
├── Settings/
│   ├── SettingsView.swift
│   └── SettingsViewModel.swift
└── Components/ (shared across multiple screens)
    ├── MealSuggestionCard.swift
    ├── CustomButton.swift
    └── ErrorView.swift
```

**Component Sharing Rule**: If a component is used by 2+ screens, it goes in `/Components`. Keep files under 500 lines - split into smaller components if needed.

### State Management: MVVM with ViewModels
```swift
// Clean separation for maintainable development
@StateObject private var viewModel = HomeViewModel()
```

**Why**: Clean architecture without over-engineering. Business logic stays in ViewModels, views stay simple and declarative.

**Pattern**:
- Views handle UI rendering and user interactions
- ViewModels handle business logic, API calls, and state management
- Models represent data structures
- Services handle external dependencies

---

## 🔧 **Technical Standards**

### Error Handling: Multi-Level Approach
- **Critical errors** (no internet, API down): User-friendly alerts
- **Non-critical errors** (suggestion failed): Toast notifications  
- **Form errors**: Inline error states
- **Loading states**: Built into UI components

```swift
// Example pattern
@State private var errorToast: String?
@State private var showCriticalAlert = false
@State private var isLoading = false
```

### Networking: Supabase Swift Client + Service Layer
```swift
// NetworkService.swift - thin wrapper around Supabase
class NetworkService {
    private let supabase = SupabaseClient(/* config */)
    
    func getSuggestion() async throws -> MealSuggestion {
        // Clean async/await with Supabase client
    }
}
```

**Why**: Supabase client handles auth/realtime, but wrap it for testability and cleaner ViewModels.

### Testing Strategy: Business Logic Focus
- **Unit tests** for ViewModels and service classes
- **Manual testing** for UI flows (faster for MVP)
- **Skip UI tests** for now (time constraint)

```swift
// Focus testing on core logic
class HomeViewModelTests: XCTestCase {
    func testSuggestionLoading() { /* test business logic */ }
}
```

---

## 📦 **Dependencies & Libraries**

### ✅ Approved Dependencies
- **Supabase Swift**: Database/auth (core requirement)
- **Kingfisher**: Image loading/caching (proven, reliable)
- **SwiftUI-Introspect**: If you need native iOS features SwiftUI doesn't expose

### ❌ Avoid These
- Complex state management libs (TCA, Redux-like)
- Heavy analytics SDKs (use Supabase events)
- UI component libraries (build custom for your design)

**Dependency Discipline**: Only add what you truly need. Each dependency adds complexity and potential points of failure.

---

## 🌿 **Git Workflow: Feature Branches (Light)**

```bash
main
├── feature/suggestion-engine
├── feature/user-preferences  
└── feature/premium-paywall
```

**Process**:
1. Create feature branch for each major feature
2. Self-review your code before merging (good habit even solo)
3. Merge directly to main when feature is complete
4. No complex PR process since you're solo

**Commit Standards**:
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`
- Keep commits atomic and descriptive
- Commit frequently to avoid losing work

---

## 💻 **Coding Standards**

### SwiftUI Best Practices
```swift
// ✅ Good - Clean, readable, follows conventions
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                suggestionCard
                actionButtons
            }
            .navigationTitle("What to Eat?")
        }
        .task {
            await viewModel.loadSuggestion()
        }
    }
    
    private var suggestionCard: some View {
        // Extract complex views into computed properties
    }
}

// ❌ Avoid - Massive body, unclear structure
struct HomeView: View {
    var body: some View {
        // 200+ lines of nested views
    }
}
```

### Naming Conventions
- **Views**: `HomeView`, `SettingsView`, `SuggestionCard`
- **ViewModels**: `HomeViewModel`, `SettingsViewModel`
- **Services**: `NetworkService`, `AuthService`, `AnalyticsService`
- **Models**: `MealSuggestion`, `UserProfile`, `Recipe`

### Function & Variable Naming
```swift
// ✅ Clear, descriptive names
func calculateDailyCalories() -> Int { }
func handleMealSave() { }
func formatCalories(_ calories: Int) -> String { }

// ❌ Avoid abbreviated or unclear names
func calc() -> Int { }
func handle() { }
func fmt(_ c: Int) -> String { }
```

---

## 🎨 **UI/UX Standards**

### SwiftUI Component Guidelines
- **Single responsibility** - One component, one job
- **Composition over inheritance** - Build with smaller pieces
- **Props drilling is OK for MVP** - Context only when truly global
- **Loading states everywhere** - Users should always know what's happening

### Performance Guidelines
- Use `LazyVStack`/`LazyHStack` for long lists
- Optimize images with proper sizing and compression
- Implement proper caching for network requests
- Use `@State` sparingly - prefer `@StateObject` for complex state

---

## 📊 **Quality Metrics**

### Code Quality Targets
- **File Size**: < 500 lines per file
- **Function Size**: < 50 lines per function
- **Cyclomatic Complexity**: < 10 per function
- **Test Coverage**: > 80% for business logic

### Performance Targets
- **App Launch**: < 3 seconds cold start
- **API Response**: P95 < 3 seconds
- **Memory Usage**: < 100MB typical usage
- **Crash Rate**: < 0.1%

---

## 🔐 **Security & Privacy**

### Data Handling
- **Minimal data collection** - Only collect what's absolutely needed
- **Encryption everywhere** - At rest and in transit
- **User control** - Easy data export/deletion
- **Input validation** - Never trust user input

### API Security
- Rate limiting on all endpoints
- Proper authentication token handling
- Secure storage using Keychain
- Error messages don't leak system details

---

## 🚀 **Deployment Standards**

### Release Process
- **Feature flags** for big changes
- **Rollback plan** always ready
- **Staging environment** mirrors production
- **User communication** for breaking changes

### Monitoring
- Track user-facing errors first
- Monitor performance regressions
- Business metrics (suggestions created, recipes saved)
- Cost monitoring (API usage, storage)

---

## 📝 **Documentation Standards**

### Code Documentation
- Document **why**, not **what**
- Use Swift's documentation comments for public APIs
- Keep README updated with setup instructions
- Document architectural decisions in ADRs

### Comments Guidelines
```swift
// ✅ Good - Explains the why
// Cache suggestions for 2-4 hours to reduce API costs 
// while maintaining fresh content for users
private func cacheStrategy() { }

// ❌ Bad - Explains the obvious
// This function caches suggestions
private func cacheStrategy() { }
```

---

**Remember**: This rulebook serves our core mission - ship a delightful iOS app that solves meal decision fatigue in 4-6 weeks. When in doubt, choose the option that gets us to users faster while maintaining iOS quality standards. 🍽️📱
