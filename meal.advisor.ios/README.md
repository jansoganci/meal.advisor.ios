# MealAdvisor iOS

> **"What should I eat today?"** – The simplest way to decide what to eat, right now.

<div align="center">
  <img src="https://img.shields.io/badge/iOS-16.0+-blue.svg" alt="iOS Version">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/Xcode-15+-blue.svg" alt="Xcode Version">
  <img src="https://img.shields.io/badge/SwiftUI-✓-green.svg" alt="SwiftUI">
</div>

## 🎯 **What is MealAdvisor?**

MealAdvisor is a native iOS app that solves meal decision fatigue with a **single tap**. Built with SwiftUI and following Apple's Human Interface Guidelines, it delivers personalized meal suggestions instantly – no complex planning, no calorie tracking, just great food ideas when you need them.

### **Core Philosophy**
- **Ship fast, iterate faster** – Working iOS app over perfect architecture
- **One-tap decision relief** – From "What should I eat?" to "Let's cook!" in seconds
- **iPhone 5s quality execution** – Simple, reliable, delightful
- **Mobile-first reality** – Built for busy people on the go

## ✨ **Features**

### **🏠 Core Experience**
- **Instant meal suggestions** with one-tap generation
- **Smart personalization** based on dietary preferences and cooking time
- **Beautiful recipe cards** with high-quality food photography
- **Recipe details** with ingredients, instructions, and nutrition info
- **Time-aware suggestions** (breakfast, lunch, dinner automatically detected)

### **⚙️ Personalization**
- **Dietary restrictions** – Vegetarian, vegan, gluten-free, and more
- **Cooking time preferences** – From 15-minute quick meals to weekend projects
- **Cuisine preferences** – Italian, Asian, Mediterranean, Mexican, American
- **Difficulty levels** – Easy weeknight meals to challenging weekend cooking

### **💎 Premium Features** *(Available Now)*
- **Unlimited favorites** – Save and organize your favorite meals ✅
- **Unlimited suggestions** – No daily limits on meal ideas ✅
- **Cross-device sync** – Access favorites from any device ✅
- **Advanced personalization** – Enhanced meal suggestions ✅
- **Priority support** – Get help when you need it

## 🚀 **Getting Started**

### **Prerequisites**
- **Xcode 15+** with iOS 16+ SDK
- **macOS Ventura** or later
- **Active Apple Developer account** (for device testing)
- **Supabase account** (for backend services)

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/meal.advisor.ios.git
   cd meal.advisor.ios
   ```

2. **Open in Xcode**
   ```bash
   open meal.advisor.ios/meal.advisor.ios.xcodeproj
   ```

3. **Configure Supabase**
   - Copy `meal.advisor.ios/Resources/Secrets.example.plist` to `Secrets.plist`
   - Add your Supabase URL and API key:
   ```xml
   <key>SUPABASE_URL</key>
   <string>your-supabase-url</string>
   <key>SUPABASE_ANON_KEY</key>
   <string>your-supabase-anon-key</string>
   ```

4. **Build and run**
   - Select your target device or simulator
   - Press `⌘R` or click the Run button

### **Database Setup**

The app requires a Supabase backend with the following tables:

```sql
-- Run these migrations in your Supabase SQL editor
-- Located in: supabase/migrations/
\i supabase/migrations/20250921180224_create_meals_schema.sql
\i supabase/migrations/20250921190000_add_recipe_collection.sql
```

## 🏗️ **Project Architecture**

### **Technology Stack**
- **SwiftUI** – Modern, declarative UI framework
- **MVVM Architecture** – Clean separation of concerns
- **Supabase** – Backend-as-a-Service for data and auth
- **Kingfisher** – Efficient image loading and caching
- **StoreKit 2** – Native subscription management

### **Project Structure**
```
meal.advisor.ios/
├── meal.advisor.ios/              # Main iOS app
│   ├── Views/                     # SwiftUI views (screen-based)
│   │   ├── Home/                  # Main suggestion screen
│   │   ├── Recipe/                # Recipe detail modal
│   │   ├── Favorites/             # Saved meals (premium)
│   │   ├── Settings/              # User preferences
│   │   └── Components/            # Reusable UI components
│   ├── Models/                    # Data structures
│   ├── Services/                  # Business logic & API layer
│   ├── Utilities/                 # Extensions & helpers
│   └── Resources/                 # Assets, strings, config
├── docs/                          # Comprehensive planning docs
├── supabase/                      # Backend configuration
└── reference/                     # Research & analysis
```

### **Key Dependencies**
```swift
// Swift Package Manager
.package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
.package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0")
```

## 📱 **Development**

### **Running the App**
```bash
# Open in Xcode
open meal.advisor.ios/meal.advisor.ios.xcodeproj

# Or build from command line
xcodebuild -project meal.advisor.ios/meal.advisor.ios.xcodeproj \
           -scheme meal.advisor.ios \
           -destination "platform=iOS Simulator,name=iPhone 15" \
           build
```

### **Testing**
```bash
# Run unit tests
xcodebuild -project meal.advisor.ios/meal.advisor.ios.xcodeproj \
           -scheme meal.advisor.ios \
           -destination "platform=iOS Simulator,name=iPhone 15" \
           test
```

### **Code Style**
- **Follow Apple's Swift API Design Guidelines**
- **4-space indentation**, braces on same line
- **Prefer value types** (structs) over reference types
- **Use guard statements** for early exits, avoid force unwraps

## 🎨 **Design System**

### **Brand Colors**
- **Primary Orange**: `#FF6B35` (light) / `#FF7A47` (dark)
- **Accent Green**: `#34C759` (light) / `#30D158` (dark)

### **Typography**
- **System fonts** with Dynamic Type support
- **Accessibility-first** approach with VoiceOver labels
- **High contrast** mode compatibility

### **Components**
- **Custom buttons** with haptic feedback
- **Loading shimmers** for skeleton states
- **Toast notifications** for user feedback
- **Modal presentations** following iOS conventions

## 📊 **Performance Targets**

- **App Launch**: < 2 seconds cold start
- **Suggestion Loading**: < 3 seconds (P95)
- **Memory Usage**: < 100MB typical
- **Crash-Free Rate**: > 99.5%
- **App Store Rating**: > 4.5 stars target

## 🗺️ **Roadmap**

### **Phase 1: Foundation** *(Week 1)*
- [x] Project setup & SwiftUI architecture
- [x] Design system implementation
- [x] Basic suggestion flow
- [x] Supabase integration

### **Phase 2: Core Features** *(Week 2)* ✅
- [x] Recipe detail screens
- [x] User preferences & settings
- [x] Offline mode & caching
- [x] Push notifications

### **Phase 3: Premium Features** *(Week 3)* ✅
- [x] StoreKit 2 subscriptions
- [x] Favorites system with search/filter
- [x] Authentication (Apple + Google + Email)
- [x] Paywall implementation
- [x] Analytics service

### **Phase 3.5: Auth & Integration** *(Week 3.5)* ✅
- [x] Optional authentication (JIT prompts)
- [x] Data synchronization services
- [x] Conflict resolution strategies
- [x] Cross-device sync

### **Phase 4: Polish & Launch** *(Week 4)* 🚧 *75% Complete*
- [x] VoiceOver accessibility labels
- [x] Localization strings prepared
- [x] ImageService implementation (UnsplashService)
- [x] Usage quota system (5/day free, unlimited premium)
- [x] Optional authentication (JIT prompts)
- [x] Settings navigation bug fixes
- [x] Cuisine & diet updates (Turkish, No Pork)
- [ ] Performance testing
- [ ] Unit tests

### **Phase 5: Launch Preparation** *(Week 5-6)* ⏳
- [ ] TestFlight beta testing
- [ ] App Store assets & legal docs
- [ ] Final bug fixes
- [ ] App Store submission

## 🤝 **Contributing**

This is currently a solo development project focused on rapid MVP delivery. Contributions will be welcomed after the initial App Store launch.

### **Development Philosophy**
1. **User value first** – Every feature must solve a real problem
2. **iOS-native excellence** – Follow Apple HIG religiously
3. **Performance matters** – Mobile users have zero patience
4. **Ship and learn** – Real user feedback > theoretical perfection

## 📄 **License**

This project is proprietary software. All rights reserved.

## 📞 **Support**

- **Documentation**: Check the `/docs` folder for detailed guides
- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Email**: [your-email@domain.com](mailto:your-email@domain.com)

---

<div align="center">
  <p><strong>Built with ❤️ for iPhone users who just want to know what to eat</strong></p>
  <p>
    <a href="https://apps.apple.com/app/mealadvisor">📱 Download on the App Store</a> • 
    <a href="/docs/blueprint.md">📖 Read the Blueprint</a> • 
    <a href="/roadmap.md">🗺️ View Roadmap</a>
  </p>
</div>
