# MealAdvisor Development Roadmap

*Last Updated: September 21, 2025*  
*Project: MealAdvisor iOS App - "What Should I Eat Today?" Utility*

---

## 🎯 **Mission: From Zero to App Store Hero**

**Timeline**: 4-6 weeks  
**Philosophy**: Ship fast, iterate faster - iPhone 5s quality execution  
**Goal**: Launch a delightful meal suggestion app that users love daily  

---

## 📅 **PHASE 1: FOUNDATION (Week 1)**
*Goal: Solid foundation with basic suggestion flow working*

### 🏗️ **Day 1-2: Project Setup & Architecture**

#### ✅ **Project Foundation Checklist**
- [x] Create new Xcode project (iOS 16+, SwiftUI)
- [x] Setup folder structure according to `project_structure.md`
- [x] Add Swift Package Manager dependencies:
  - [x] Supabase Swift SDK
  - [x] Kingfisher (image loading)
- [x] Configure `Info.plist` permissions:
  - [x] Internet access
  - [x] Push notifications (optional)
- [x] Setup color assets in `Assets.xcassets`:
  - [x] PrimaryOrange (#FF6B35 light, #FF7A47 dark)
  - [x] AccentGreen (#34C759 light, #30D158 dark)
- [x] Create app icon set (already designed)
- [x] Configure bundle identifier and signing

#### 🎨 **Design System Implementation**
- [x] Create `Color+Extensions.swift` with brand colors
- [x] Create `Font+Extensions.swift` with typography scale
- [x] Build `CustomButton.swift` component (Primary, Secondary, Text)
- [x] Build `LoadingShimmer.swift` skeleton component
- [x] Test light/dark mode switching

#### 📱 **Basic App Structure**
- [x] Implement `MealAdvisorApp.swift` entry point
- [x] Create `ContentView.swift` with TabView
- [x] Setup basic navigation (Home, Favorites, Settings tabs)
- [x] Create placeholder views for each tab
- [x] Test tab switching and navigation

**🎯 End of Day 2 Goal**: App launches, shows 3 tabs, design system works

---

### 🏠 **Day 3-4: Home Screen Core**

#### ✅ **Data Models Checklist**
- [x] Create `Meal.swift` with complete structure:
  - [x] Basic properties (id, title, description)
  - [x] Metadata (prepTime, difficulty, cuisine)
  - [x] Diet tags enum
  - [x] Ingredients and instructions arrays
- [x] Create `UserPreferences.swift` model
- [x] Create `AppState.swift` for global state management
- [x] Test model serialization (Codable)

- [x] Create `HomeView.swift` basic layout
- [x] Create `HomeViewModel.swift` with @StateObject pattern
- [x] Build `SuggestionCard.swift` component:
  - [x] Hero image placeholder (16:9 aspect ratio)
  - [x] Meal title and description
  - [x] Metadata badges (time, difficulty, cuisine)
  - [x] Proper spacing and styling
- [x] Create `TimeGreeting.swift` component (Good morning/afternoon/evening)
- [x] Add primary "Get New Suggestion" button
- [x] Add secondary action buttons (See Recipe, Save, Order)

- [x] Implement shimmer loading animation
- [x] Create loading state for suggestion generation
- [x] Add error state handling
- [x] Test all states (loading, success, error)

**🎯 End of Day 4 Goal**: Home screen looks pixel-perfect, shows static meal card

---

### 🌐 **Day 5-7: Supabase Integration**

#### ✅ **Backend Setup Checklist**
- [x] Setup Supabase project
- [x] Create database tables:
  - [x] `meals` table with all required columns
  - [ ] `users` table for user profiles
  - [x] `user_preferences` table
  - [ ] `favorites` table (for premium)
- [x] Configure Row Level Security (RLS) policies
- [x] Test database connection from iOS app

#### 🔧 **Service Layer Implementation**
- [x] Create `NetworkService.swift` Supabase wrapper
- [x] Create `MealService.swift` for meal suggestions:
  - [x] `generateSuggestion()` method
  - [x] `getRecipeDetails()` method
  - [x] Proper error handling
- [] Create `ImageService.swift` for Unsplash integration
- [x] Test API calls with sample data

#### 📊 **Sample Data**
- [x] Curate 20 initial recipes across 5 cuisines:
  - [x] 4 Italian recipes
  - [x] 4 American recipes  
  - [x] 4 Asian recipes
  - [x] 4 Mediterranean recipes
  - [x] 4 Mexican recipes
- [x] Add proper images from Unsplash
- [x] Test recipe variety and quality
- [x] Populate database with sample data

**🎯 End of Week 1 Goal**: ✅ Home screen loads real meal suggestions from Supabase

---

## 📅 **PHASE 2: CORE FEATURES (Week 2)**
*Goal: Complete user experience with recipe details and preferences*

### 📄 **Day 8-9: Recipe Detail Screen**

#### ✅ **Recipe Detail Implementation**
- [x] Create `RecipeDetailView.swift` as full-screen modal
- [x] Create `RecipeViewModel.swift` for data handling
- [x] Build recipe components:
  - [x] Hero image with proper aspect ratio
  - [x] Recipe title and metadata
  - [x] `IngredientsList.swift` component
  - [x] `InstructionsView.swift` step-by-step
  - [x] `NutritionBadges.swift` for dietary info
- [x] Add navigation bar with close/share/save buttons
- [x] Implement modal presentation from home screen
- [x] Test scrolling and layout on different screen sizes

#### 🎨 **Polish & Interactions**
- [x] Add smooth modal presentation animation
- [x] Implement haptic feedback on button taps
- [x] Add share functionality (native iOS share sheet)
- [x] Test accessibility (VoiceOver labels)
- [x] Optimize for Dynamic Type scaling

**🎯 End of Day 9 Goal**: Tap "See Recipe" shows beautiful, scrollable recipe detail

---

### ⚙️ **Day 10-11: Settings & Preferences**

#### ✅ **Settings Screen Implementation**
- [ ] Create `SettingsView.swift` with grouped list design
- [ ] Create `SettingsViewModel.swift` for preferences management
- [ ] Build settings components:
  - [ ] `SettingsRow.swift` for list items
  - [ ] `PreferenceToggle.swift` for switches
- [x] Create preference sub-screens:
  - [x] `DietaryRestrictionsView.swift` (multi-select)
  - [x] `CookingTimeView.swift` (time picker)
  - [x] `CuisinePreferencesView.swift` (cuisine selection)
- [x] Implement `UserPreferencesService.swift` for persistence

#### 🔧 **Preferences Integration**
- [x] Connect preferences to meal suggestion algorithm
- [x] Add preference filtering in `MealService.swift`
- [x] Test suggestion personalization
- [x] Add preference reset functionality
- [ ] Implement preference sync (local storage)

**🎯 End of Day 11 Goal**: Users can set preferences and get personalized suggestions

---

### 🎯 **Day 12-14: Polish & Performance**

#### ✅ **Performance Optimization**
- [x] Implement image caching with Kingfisher
- [ ] Add suggestion prefetching (load 2-3 ahead)
- [ ] Optimize database queries
- [ ] Add offline mode with cached suggestions
- [ ] Test app performance on older devices

#### 🔄 **Enhanced User Experience**
- [x] Add "Show Another" button with smooth transitions
- [ ] Implement suggestion history (avoid recent repeats)
- [ ] Add meal rating system (thumbs up/down)
- [ ] Create better error states with retry actions
- [ ] Add empty states for all screens

#### 📱 **iOS Integration**
- [ ] Add app shortcuts (3D Touch/long press)
- [ ] Implement basic push notifications setup
- [ ] Add proper app lifecycle handling
- [ ] Test app backgrounding and restoration

**🎯 End of Week 2 Goal**: Smooth, polished core experience ready for daily use

---

## 📅 **PHASE 3: PREMIUM FEATURES (Week 3)**
*Goal: Monetization with favorites and subscription system*

### 💎 **Day 15-16: Premium Infrastructure**

#### ✅ **StoreKit 2 Setup**
- [ ] Configure App Store Connect with subscription products:
  - [ ] Monthly: $2.99 with 3-day free trial
  - [ ] Annual: $24.99 with no free trial
- [ ] Create `PurchaseService.swift` with StoreKit 2
- [ ] Implement subscription validation
- [ ] Add receipt verification
- [ ] Test subscription flow in sandbox

#### 🔐 **Authentication System**
- [ ] Create `AuthService.swift` for Sign in with Apple
- [ ] Implement user authentication flow
- [ ] Connect auth to Supabase user management
- [ ] Add sign-out functionality
- [ ] Test authentication edge cases

**🎯 End of Day 16 Goal**: Users can sign in and purchase subscriptions

---

### ❤️ **Day 17-18: Favorites System**

#### ✅ **Favorites Implementation**
- [x] Create `FavoritesView.swift` with grid layout
- [x] Create `FavoritesViewModel.swift` with premium gating (integrated into RecipeViewModel)
- [x] Build favorites components:
  - [x] `FavoriteMealCard.swift` for grid items
  - [x] `EmptyFavorites.swift` for empty state (built into FavoritesView)
- [x] Create `FavoritesService.swift` for data management
- [x] Implement add/remove favorites functionality

#### 🎨 **Premium User Experience**
- [x] Add heart animation when saving favorites (haptic feedback implemented)
- [ ] Implement favorites sync across devices
- [ ] Create favorites search and filtering
- [ ] Add favorites export functionality
- [ ] Test favorites with large collections (50+ items)

**🎯 End of Day 18 Goal**: Premium users can save and organize favorite meals

---

### 💰 **Day 19-21: Paywall & Premium Polish**

#### ✅ **Paywall Implementation**
- [ ] Create `PaywallView.swift` modal design
- [ ] Create `PaywallViewModel.swift` with purchase logic
- [ ] Build paywall components:
  - [ ] `FeaturesList.swift` benefits list
  - [ ] `PricingCard.swift` subscription options
- [ ] Implement smart paywall triggers:
  - [ ] After 5 daily suggestions
  - [x] When accessing favorites
  - [ ] From settings screen
- [ ] Add "Maybe Later" escape route

#### 🎯 **Premium Feature Gating**
- [x] Gate favorites behind premium subscription
- [ ] Add premium badges throughout app
- [ ] Implement feature unlock animations
- [ ] Create premium onboarding flow
- [x] Test free vs premium user experiences

#### 📊 **Analytics Integration**
- [ ] Create `AnalyticsService.swift` privacy-first tracking
- [ ] Track key metrics:
  - [ ] Daily active users
  - [ ] Suggestion generation rate
  - [ ] Premium conversion rate
  - [ ] Feature usage patterns
- [ ] Implement Supabase analytics integration
- [ ] Test analytics data collection

**🎯 End of Week 3 Goal**: Complete premium experience with working monetization

---

## 📅 **PHASE 4: POLISH & LAUNCH (Week 4)**
*Goal: App Store ready with professional polish*

### ♿ **Day 22-23: Accessibility & Localization**

#### ✅ **Accessibility Implementation**
- [ ] Add VoiceOver labels to all interactive elements
- [ ] Test with VoiceOver enabled
- [ ] Implement Dynamic Type support:
  - [ ] Test at largest accessibility sizes
  - [ ] Ensure layout adapts properly
- [ ] Add high contrast mode support
- [ ] Test with Switch Control
- [ ] Add accessibility hints for complex interactions

#### 🌍 **Localization Preparation**
- [x] Extract core user-facing strings to `Localizable.strings`
- [ ] Implement proper string formatting
- [ ] Test with longer text (German simulation)
- [ ] Add right-to-left language support basics
- [ ] Prepare for future localization

**🎯 End of Day 23 Goal**: App is fully accessible and localization-ready

---

### 🔔 **Day 24-25: Push Notifications & Polish**

#### ✅ **Push Notifications**
- [ ] Create `NotificationService.swift`
- [ ] Implement meal reminder notifications:
  - [ ] "Time for lunch! Tap for a suggestion"
  - [ ] "Good evening! What's for dinner?"
- [ ] Add notification permission request
- [ ] Implement notification scheduling
- [ ] Test notification delivery and handling
- [ ] Add notification settings in app

#### ✨ **Final Polish**
- [ ] Add haptic feedback throughout app
- [ ] Implement smooth micro-animations
- [ ] Polish loading states and transitions
- [ ] Add app icon badge for notifications
- [ ] Test app in all edge cases
- [ ] Performance testing on various devices

**🎯 End of Day 25 Goal**: Professional-quality app with notifications

---

### 🧪 **Day 26-28: Testing & Optimization**

#### ✅ **Quality Assurance**
- [ ] Write unit tests for ViewModels:
  - [ ] `HomeViewModelTests.swift`
  - [ ] `FavoritesViewModelTests.swift`
  - [ ] `SettingsViewModelTests.swift`
- [ ] Write unit tests for Services:
  - [ ] `MealServiceTests.swift`
  - [ ] `AuthServiceTests.swift`
  - [ ] `PurchaseServiceTests.swift`
- [ ] Create UI tests for critical flows:
  - [ ] Suggestion generation flow
  - [ ] Premium upgrade flow
  - [ ] Navigation testing

#### 🔍 **Bug Fixing & Edge Cases**
- [ ] Test with poor network conditions
- [ ] Test with empty database
- [ ] Test subscription edge cases
- [ ] Test app launch scenarios
- [ ] Memory leak testing with Instruments
- [ ] Battery usage optimization

#### 📊 **Performance Validation**
- [ ] Measure app launch time (< 2 seconds target)
- [ ] Measure suggestion loading (< 3 seconds target)
- [ ] Test memory usage (< 100MB target)
- [ ] Validate smooth 60fps animations
- [ ] Test on iPhone SE and iPhone 15 Pro Max

**🎯 End of Day 28 Goal**: Bug-free, performant app ready for TestFlight

---

## 📅 **PHASE 5: LAUNCH PREPARATION (Week 5-6)**
*Goal: App Store submission and go-to-market*

### 🚀 **Week 5: TestFlight & Feedback**

#### ✅ **TestFlight Deployment**
- [ ] Create App Store Connect listing
- [ ] Upload first TestFlight build
- [ ] Invite 10-20 beta testers
- [ ] Create beta testing guidelines
- [ ] Monitor crash reports and feedback

#### 📝 **App Store Assets**
- [ ] Create app screenshots (6.7", 6.5", 5.5" displays)
- [ ] Write app description and keywords
- [ ] Create app preview video (optional)
- [ ] Design promotional graphics
- [ ] Prepare press kit materials

#### 🔧 **Feedback Integration**
- [ ] Collect and analyze beta feedback
- [ ] Fix critical bugs from TestFlight
- [ ] Iterate on user experience issues
- [ ] Optimize onboarding based on feedback
- [ ] Prepare final release candidate

---

### 📱 **Week 6: App Store Launch**

#### ✅ **Final Launch Checklist**
- [ ] Complete App Store Review Guidelines compliance
- [ ] Submit for App Store review
- [ ] Prepare launch day marketing materials
- [ ] Setup app analytics and monitoring
- [ ] Create customer support system

#### 🎉 **Launch Day Activities**
- [ ] Monitor app review status
- [ ] Prepare for launch day social media
- [ ] Setup app store optimization (ASO)
- [ ] Monitor initial user feedback
- [ ] Track key metrics and conversion rates

---

## 📊 **SUCCESS METRICS & GOALS**

### 🎯 **Technical Targets**
- [ ] **App Launch Time**: < 2 seconds cold start
- [ ] **Suggestion Loading**: < 3 seconds P95
- [ ] **Crash-Free Rate**: > 99.5%
- [ ] **Memory Usage**: < 100MB typical
- [ ] **App Store Rating**: > 4.5 stars

### 📈 **Business Targets**
- [ ] **Day 7 Retention**: > 35%
- [ ] **Day 30 Retention**: > 25%  
- [ ] **Premium Conversion**: 3-7%
- [ ] **Daily Active Users**: Growing week-over-week
- [ ] **Session Duration**: 1-3 minutes (efficient, not addictive)

### 👥 **User Experience Targets**
- [ ] **Time to First Value**: < 45 seconds on first run
- [ ] **Task Completion Rate**: > 90%
- [ ] **User Satisfaction**: "Just works" feedback
- [ ] **Support Tickets**: < 1% of users
- [ ] **Feature Adoption**: Users return next day > 60%

---

## 🔧 **DEVELOPMENT TOOLS & SETUP**

### 📱 **Required Tools**
- [ ] Xcode 15+ with iOS 16+ SDK
- [ ] Supabase account and project setup
- [ ] App Store Connect developer account
- [ ] TestFlight access for beta testing
- [ ] Unsplash developer API key

### 📦 **Dependencies Management**
```swift
// Package.swift dependencies
.package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
.package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0")
```

### 🔐 **Environment Setup**
- [ ] Configure Supabase environment variables
- [ ] Setup API keys and secrets
- [ ] Configure push notification certificates
- [ ] Setup App Store Connect API keys
- [ ] Configure analytics and monitoring

---

## 🚨 **RISK MITIGATION**

### ⚠️ **Potential Blockers & Solutions**
- **Supabase Integration Issues**: Have backup sample data ready
- **StoreKit Testing Problems**: Use Xcode StoreKit testing framework
- **App Store Review Rejection**: Follow guidelines strictly, have appeal ready
- **Performance Issues**: Profile early and often with Instruments
- **Design Complexity**: Stick to iOS standards, avoid custom components

### 🔄 **Contingency Plans**
- **Week 1 Delay**: Cut advanced animations, focus on core functionality
- **Week 2 Delay**: Simplify preferences, use basic toggles only
- **Week 3 Delay**: Launch without premium features, add post-launch
- **Week 4 Delay**: Skip notifications, launch with core experience only

---

## 🎯 **DAILY STANDUP QUESTIONS**

### ✅ **Track Progress Daily**
1. **What did I complete yesterday?**
2. **What will I work on today?**
3. **What blockers do I have?**
4. **Am I on track for this week's goal?**
5. **Do I need to adjust scope or timeline?**

### 📊 **Weekly Review Questions**
1. **Did I hit this week's main goal?**
2. **What took longer than expected?**
3. **What went faster than planned?**
4. **What should I do differently next week?**
5. **Am I still on track for 4-6 week launch?**

---

## 🎉 **LAUNCH SUCCESS CRITERIA**

### ✅ **Minimum Viable Product (MVP) Definition**
- [ ] Users can get meal suggestions instantly
- [ ] Recipe details are accessible and readable  
- [ ] Basic preferences work (diet restrictions, time)
- [ ] Premium subscription system functions
- [ ] App is stable and crash-free
- [ ] Performance meets targets (< 3s suggestion loading)

### 🚀 **Launch Day Readiness**
- [ ] App Store listing is complete and approved
- [ ] TestFlight feedback has been addressed
- [ ] All critical bugs are fixed
- [ ] Analytics and monitoring are in place
- [ ] Customer support system is ready
- [ ] Marketing materials are prepared

---

**Remember: This roadmap serves our core mission - ship a delightful iOS app that solves meal decision fatigue in 4-6 weeks. Stay focused on the iPhone 5s philosophy: simplicity, reliability, and user delight. When in doubt, ship something that works perfectly rather than something complex that doesn't.** 

**You've got this! 🚀📱✨**
