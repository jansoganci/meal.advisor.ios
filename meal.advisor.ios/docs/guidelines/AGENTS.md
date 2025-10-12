# MealAdvisor Repository Guidelines

*Last Updated: September 21, 2025*  
*Project: MealAdvisor iOS App - "What Should I Eat Today?" Utility*

---

## 📱 **Project Philosophy**

**iPhone 5s-Inspired Development**: Clean, intuitive, elegant design with seamless functionality. Every architectural decision serves the core mission - help users decide what to eat with zero friction.

**Core Principles:**
- **Ship fast, iterate faster** - Working iOS app > perfect architecture
- **"Invisible interface"** - UI disappears, users focus on their task
- **iOS-native excellence** - Follow Apple HIG religiously
- **Single-purpose screens** - One primary action per screen

---

## 🏗️ **Project Structure & Architecture**

### Root Directory Organization
```
meal.advisor.ios/
├── meal.advisor.ios/                 // Main iOS app source
│   ├── App/                          // App entry point & lifecycle
│   ├── Views/                        // MVVM View layer (screen-based)
│   ├── Models/                       // Data structures
│   ├── Services/                     // Business logic & API layer
│   ├── Utilities/                    // Extensions & helpers
│   └── Resources/                    // Assets, strings, entitlements
├── docs/                             // Comprehensive planning documents
│   ├── blueprint.md                  // Main project overview
│   ├── design_rulebook.md           // iOS HIG-compliant design system
│   ├── structure_rulebook.md        // UX structure & navigation
│   ├── project_structure.md         // SwiftUI implementation plan
│   └── wireframes.md                // Pixel-perfect screen layouts
├── reference/                        // Research & analysis documents
├── roadmap.md                        // 4-6 week execution plan
└── AGENTS.md                         // This file
```

### SwiftUI Module Organization (MVVM Architecture)
```
meal.advisor.ios/meal.advisor.ios/
├── App/
│   ├── meal_advisor_iosApp.swift     // App entry point (current naming)
│   ├── ContentView.swift             // Root TabView container
│   └── AppDelegate.swift             // iOS lifecycle handling
├── Views/                            // Screen-based organization
│   ├── Home/                         // Main suggestion screen
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   └── Components/
│   ├── Recipe/                       // Recipe detail modal
│   ├── Favorites/                    // Premium saved meals
│   ├── Settings/                     // User preferences
│   ├── Premium/                      // Paywall & subscription
│   └── Components/                   // Shared UI components
├── Models/
│   ├── Meal.swift                    // Core data structures
│   ├── User.swift
│   └── UserPreferences.swift
├── Services/                         // Business logic layer
│   ├── NetworkService.swift          // Supabase wrapper
│   ├── MealService.swift             // Meal suggestions API
│   ├── AuthService.swift             // Sign in with Apple
│   └── PurchaseService.swift         // StoreKit 2 subscriptions
└── Resources/
    ├── Assets.xcassets/              // Colors, images, app icon
    └── Localizable.strings           // Text localization
```

### Architecture Patterns
- **MVVM Pattern**: Views handle UI, ViewModels handle business logic
- **Service Layer**: Clean separation between UI and data/network logic
- **Single Responsibility**: Each file has one clear purpose
- **Component Sharing Rule**: Shared components go in `/Components`, screen-specific in screen folders

---

## 🛠️ **Build, Run, and Test Commands**

### Development Commands
```bash
# Open project in Xcode
open meal.advisor.ios/meal.advisor.ios.xcodeproj

# Clean build for CI/testing
xcodebuild -project meal.advisor.ios/meal.advisor.ios.xcodeproj \
           -scheme meal.advisor.ios \
           -destination "platform=iOS Simulator,name=iPhone 15" \
           build

# Run test suite
xcodebuild -project meal.advisor.ios/meal.advisor.ios.xcodeproj \
           -scheme meal.advisor.ios \
           -destination "platform=iOS Simulator,name=iPhone 15" \
           test
```

### Performance Testing
```bash
# Profile app performance
# Target: < 2s app launch, < 3s suggestion loading
# Memory: < 100MB typical usage
# Crash rate: < 0.1%
```

---

## 🎨 **Coding Style & Standards**

### Swift Style Guidelines
- **Follow Apple's Swift API Design Guidelines** strictly
- **4-space indentation**, braces on same line
- **Avoid force unwraps** - use guard statements for early exits
- **Prefer value types** (structs) over reference types when appropriate

### Naming Conventions
```swift
// Types: UpperCamelCase
struct MealSuggestion { }
class HomeViewModel { }
enum Difficulty { }

// Properties, functions, enum cases: lowerCamelCase
var currentMeal: Meal
func generateSuggestion() -> Meal
case easy, medium, hard

// Assets: snake_case (matches current Assets.xcassets)
Color("primary_orange")
Image("meal_placeholder")
```

### Code Organization Rules
- **500 Line Rule**: Split files when they exceed 500 lines
- **MVVM Separation**: Views handle UI, ViewModels handle logic
- **Service Pattern**: Wrap external dependencies (Supabase, StoreKit)
- **Error Boundaries**: Handle errors at appropriate levels

---

## 🧪 **Testing Strategy**

### Test Organization
```
meal.advisor.iosTests/
├── ViewModelTests/
│   ├── HomeViewModelTests.swift
│   ├── FavoritesViewModelTests.swift
│   └── SettingsViewModelTests.swift
├── ServiceTests/
│   ├── MealServiceTests.swift
│   ├── AuthServiceTests.swift
│   └── PurchaseServiceTests.swift
└── ModelTests/
    ├── MealTests.swift
    └── UserPreferencesTests.swift
```

### Testing Guidelines
- **Unit tests for ViewModels and Services** - Focus on business logic
- **Manual testing for UI flows** - Faster iteration for MVP
- **XCTest with descriptive names**: `test_generateSuggestion_returnsPersonalizedMeal`
- **Test coverage near critical user flows**: Suggestion generation, premium conversion

---

## 📝 **Git Workflow & Commit Guidelines**

### Branching Strategy
```bash
main                    # Production-ready code
├── feature/home-screen # Major feature development
├── feature/premium     # Premium subscription system
└── hotfix/crash-fix    # Critical bug fixes
```

### Commit Message Format
```bash
# Use conventional commits with clear, imperative messages
feat: Add meal suggestion card component
fix: Resolve crash when loading recipe details  
refactor: Extract networking logic to service layer
docs: Update project structure documentation
test: Add unit tests for HomeViewModel
```

### Code Review Process
- **Self-review before merging** (good habit even solo)
- **Reference planning documents** in commit messages
- **Include simulator screenshots** for UI changes
- **Link to roadmap items** when applicable

---

## 🚀 **Development Workflow**

### Daily Development Process
1. **Check roadmap.md** for current phase goals
2. **Reference appropriate rulebook** (design, structure, etc.)
3. **Follow project_structure.md** for implementation details
4. **Test on device regularly** - not just simulator
5. **Update roadmap checklist** as tasks complete

### Phase-Based Development
- **Week 1**: Foundation & core suggestion flow
- **Week 2**: Recipe details & user preferences  
- **Week 3**: Premium features & monetization
- **Week 4**: Polish, testing & accessibility
- **Week 5-6**: TestFlight & App Store launch

### Key Development References
- **docs/blueprint.md**: Overall project strategy and decisions
- **docs/design_rulebook.md**: Visual design system and iOS HIG compliance
- **docs/structure_rulebook.md**: UX structure and navigation patterns
- **docs/wireframes.md**: Pixel-perfect screen layouts
- **roadmap.md**: Detailed execution plan with daily checklists

---

## 🔧 **Dependencies & Tools**

### Required Dependencies (Swift Package Manager)
```swift
// Package.swift
.package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
.package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0")
```

### Development Tools
- **Xcode 15+** with iOS 16+ SDK
- **Supabase** for backend and authentication
- **StoreKit 2** for premium subscriptions
- **Unsplash API** for recipe images
- **TestFlight** for beta testing

### Dependency Philosophy
- **Minimal & purposeful** - Only add what you truly need
- **Proven libraries** - Kingfisher for images, Supabase for backend
- **Avoid heavy SDKs** - No complex analytics or UI libraries
- **Wrap third-party code** - Create service layers for testability

---

## 📊 **Success Metrics & Monitoring**

### Performance Targets
- **App Launch**: < 2 seconds cold start
- **Suggestion Loading**: P95 < 3 seconds  
- **Memory Usage**: < 100MB typical
- **Crash-Free Rate**: > 99.5%
- **App Store Rating**: > 4.5 stars

### User Experience Metrics
- **Time to First Value**: < 45 seconds on first run
- **Task Completion Rate**: > 90% for core flows
- **Day 7 Retention**: > 35%
- **Day 30 Retention**: > 25%

### Business Metrics  
- **Premium Conversion**: 3-7% target
- **Daily Active Users**: Growing week-over-week
- **Session Duration**: 1-3 minutes (efficient, not addictive)

---

## 🎉 **Launch Readiness Checklist**

### Pre-Launch Requirements
- [ ] All roadmap.md Phase 4 items completed
- [ ] TestFlight feedback addressed
- [ ] App Store assets prepared (screenshots, description)
- [ ] Performance targets met
- [ ] Accessibility compliance verified
- [ ] Dark mode tested on all screens

### App Store Submission
- [ ] App Store Review Guidelines compliance
- [ ] Privacy policy and terms prepared
- [ ] Customer support system ready
- [ ] Analytics and monitoring configured
- [ ] Launch day marketing materials prepared

---

**Remember: These guidelines serve our core mission - ship a delightful iOS app that solves meal decision fatigue with iPhone 5s-quality execution. Every decision should pass the "invisible interface" test - does this help or hinder the user's primary goal of deciding what to eat?** 🍽️📱✨