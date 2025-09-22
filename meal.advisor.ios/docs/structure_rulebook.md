# MealAdvisor Structure Rulebook

*Last Updated: September 21, 2025*  
*Project: MealAdvisor iOS App - "What Should I Eat Today?" Utility*

---

## 🎯 **Design Philosophy: "Invisible Interface"**

Inspired by the iPhone 5s era - peak Apple design where **the interface disappears** and users focus purely on their task. Every structural decision serves this principle:

### Core Tenets
- **Single-purpose screens** - One primary action per screen, no cognitive fatigue
- **Content-first hierarchy** - The meal is the hero, everything else supports it
- **Predictable physics** - Consistent animations and interactions build muscle memory
- **Progressive disclosure** - Show only what's needed, reveal depth on demand
- **"Just works" reliability** - No dead ends, no empty states, no decision paralysis

---

## 📱 **Screen Architecture: "Layered Simplicity"**

### Information Architecture
```
Essential → Helpful → Optional
   ↓         ↓         ↓
Always    On-demand   Hidden
 show      (tap)      (settings)
```

### Visual Weight Distribution (iPhone 5s inspired)
- **60% content** (meal suggestion card)
- **25% primary action** (main CTA button)  
- **15% secondary elements** (navigation, metadata)

---

## 🏠 **Home Screen Structure**

### Layout Philosophy: Content-First Card Design
```
┌─────────────────────────────────────┐
│  Good evening! What's for dinner?   │ ← Time-aware greeting
│                                     │
│  ┌─────────────────────────────────┐ │
│  │                                 │ │
│  │     [Hero Food Image 16:9]      │ │ ← 60% visual weight
│  │                                 │ │
│  └─────────────────────────────────┘ │
│                                     │
│        Creamy Tuscan Chicken        │ ← Clear, appetizing title
│     ⏱️ 25 min  🔥 Easy  🇮🇹 Italian  │ ← Essential metadata
│                                     │
│  ┌─────────────────────────────────┐ │
│  │      Get New Suggestion         │ │ ← Primary action (25%)
│  └─────────────────────────────────┘ │
│                                     │
│    [See Recipe]  [Save]  [Order]    │ ← Secondary actions (15%)
│                                     │
└─────────────────────────────────────┘
```

### Component Hierarchy
1. **Time-Context Greeting** (Foundation Layer)
   - Dynamic: "Good morning! What's for breakfast?"
   - Personalizes without overwhelming
   - Sets meal-time context automatically

2. **Hero Suggestion Card** (Content Layer)
   - **Image**: 16:9 aspect ratio, full-width minus margins
   - **Title**: Bold, 22pt, maximum 2 lines
   - **Metadata Badges**: Time, difficulty, cuisine as horizontal pills
   - **Background**: Subtle card elevation with rounded corners

3. **Primary Action** (Interaction Layer)
   - **"Get New Suggestion"** button
   - Full-width, brand orange, 50pt height
   - Single-tap to new suggestion (no confirmation needed)

4. **Secondary Actions** (Context Layer)
   - **See Recipe**: Navigate to full recipe
   - **Save**: Add to favorites (premium gate)
   - **Order**: Deep link to delivery services

### Interaction Patterns
```swift
// Primary flow - 80% of usage
Tap "Get New Suggestion" → Shimmer animation → New card slides in → Ready

// Secondary flows - 20% of usage  
Tap "See Recipe" → Sheet presentation → Recipe detail view
Tap "Save" → Haptic feedback → Heart animation → Added to favorites
Tap "Order" → External app → Return to MealAdvisor
```

---

## 🧭 **Navigation Structure: "Invisible Rails"**

### Primary Navigation: Tab Bar (Always Present)
```
┌─────────────────────────────────────┐
│                                     │
│           Screen Content            │
│                                     │
├─────────────────────────────────────┤
│  🏠 Home    ❤️ Favorites   ⚙️ Settings │ ← Tab bar
└─────────────────────────────────────┘
```

**Tab Configuration:**
- **Home**: `house.fill` - Primary suggestion engine
- **Favorites**: `heart.fill` - Saved meals (premium feature)
- **Settings**: `gearshape.fill` - Preferences and account

### Navigation Philosophy: "Know Where You Are"
- **Tab bar always visible** - Never lose context
- **Single back gesture** - Always know how to return
- **Modal presentations** for temporary tasks
- **Navigation pushes** for content consumption

### Screen Transition Patterns
```swift
// Content viewing (recipe details)
Home → NavigationLink → Recipe Detail (push animation)

// Quick actions (settings, save)
Home → Sheet → Settings/Action (modal presentation)

// External actions (ordering food)  
Home → External App → Return to Home (app switching)
```

---

## ❤️ **Favorites Screen Structure**

### Layout: Grid-Based Content Discovery
```
┌─────────────────────────────────────┐
│              Favorites              │ ← Navigation title
│                                     │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ [Image] │  │ [Image] │  │ [Image] │ │ ← 2-column grid
│  │  Pasta  │  │  Tacos  │  │  Salad  │ │
│  └─────────┘  └─────────┘  └─────────┘ │
│                                     │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ [Image] │  │ [Image] │  │   Add   │ │
│  │ Chicken │  │  Soup   │  │  More   │ │
│  └─────────┘  └─────────┘  └─────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### Component Structure
- **Grid Layout**: 2 columns, consistent spacing
- **Card Design**: Square aspect ratio (1:1)
- **Quick Access**: Tap any card to see recipe
- **Empty State**: Encouraging message with CTA to explore suggestions

### Interaction Patterns
- **Tap card**: Navigate to recipe detail
- **Long press**: Quick actions (remove, share)
- **Pull to refresh**: Sync favorites from cloud

---

## ⚙️ **Settings Screen Structure**

### Layout: Grouped List (iOS Standard)
```
┌─────────────────────────────────────┐
│              Settings               │
│                                     │
│  Preferences                        │
│  ├ Dietary Restrictions             │
│  ├ Cooking Time Available           │
│  └ Cuisine Preferences              │
│                                     │
│  Account                            │
│  ├ Sign in with Apple               │
│  └ Premium Subscription             │
│                                     │
│  About                              │
│  ├ Privacy Policy                   │
│  ├ Terms of Service                 │
│  └ App Version 1.0                  │
│                                     │
└─────────────────────────────────────┘
```

### Progressive Disclosure Pattern
- **Main settings**: Always visible
- **Detailed preferences**: Tap to reveal sub-screen
- **Account actions**: Clear, non-destructive
- **Legal/Info**: Present but not prominent

---

## 📄 **Recipe Detail Screen Structure**

### Layout: Content-Immersive Design
```
┌─────────────────────────────────────┐
│  ← Back          Share  Save        │ ← Navigation bar
│                                     │
│  ┌─────────────────────────────────┐ │
│  │                                 │ │
│  │     [Hero Food Image 16:9]      │ │ ← Full-width image
│  │                                 │ │
│  └─────────────────────────────────┘ │
│                                     │
│        Creamy Tuscan Chicken        │ ← Title
│     ⏱️ 25 min  🔥 Easy  👥 4 servings │ ← Metadata
│                                     │
│  Ingredients                        │ ← Section headers
│  • 1 lb chicken breast             │
│  • 1 cup heavy cream               │
│  • 2 tbsp olive oil                │
│                                     │
│  Instructions                       │
│  1. Heat olive oil in large pan... │
│  2. Season chicken with salt...    │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │         Start Cooking           │ │ ← Primary CTA
│  └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### Content Hierarchy
1. **Hero Image**: Full-width, appetizing food photography
2. **Title & Metadata**: Clear information hierarchy  
3. **Ingredients**: Scannable list with measurements
4. **Instructions**: Numbered steps, easy to follow
5. **Action Button**: Clear next step for user

### Interaction Patterns
- **Scroll to read**: Natural vertical flow
- **Tap ingredients**: Smart shopping list integration (future)
- **Start Cooking**: Timer integration (future)

---

## 🎬 **Animation & Transition System**

### Core Animation Principles (iPhone 5s Physics)
```swift
// Standard transition timing - builds muscle memory
let standardTransition: TimeInterval = 0.3

// Animation types
.spring(dampingFraction: 0.8) // Interactive elements
.easeInOut(duration: 0.3)     // Content transitions  
.easeOut(duration: 0.15)      // Quick feedback
```

### Transition Choreography
1. **New Suggestion Loading**
   ```
   Current card fades out → Shimmer placeholder → New card slides in
   Duration: 0.8s total (feels instant but polished)
   ```

2. **Navigation Transitions**
   ```
   Tab switch: Cross-fade content (0.3s)
   Modal present: Sheet slides up (0.4s iOS standard)
   Navigation push: Slide left-to-right (0.3s)
   ```

3. **Micro-Interactions**
   ```
   Button tap: Scale down 0.95 → Scale up 1.0 (0.15s)
   Save heart: Scale up 1.2 → Scale down 1.0 with color change (0.3s)
   Loading state: Gentle pulse on skeleton elements (1.5s loop)
   ```

---

## 💎 **Premium Integration Strategy**

### Philosophy: "Progressive Enhancement"
Premium enhances the experience, never blocks core functionality.

### Free Experience (Complete & Satisfying)
- **Unlimited suggestions** - Core value always available
- **Recipe viewing** - Full access to cooking instructions
- **Basic preferences** - Dietary restrictions and time constraints

### Premium Features (Additive Value)
- **Favorites collection** - Save and organize preferred meals
- **Advanced filters** - Cuisine, ingredient, nutrition preferences  
- **Weekly planning** - Meal planning calendar (Phase 2)
- **Shopping integration** - Smart grocery lists (Phase 2)

### Premium Presentation
```
┌─────────────────────────────────────┐
│  Unlock Your Full Meal Experience  │ ← Benefit-focused headline
│                                     │
│  ✓ Save unlimited favorites         │
│  ✓ Advanced meal filtering          │ ← Clear feature list
│  ✓ Weekly meal planning             │
│  ✓ Smart shopping lists             │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │    Start Free Trial - $4.99    │ │ ← Clear, honest pricing
│  └─────────────────────────────────┘ │
│                                     │
│         Maybe Later                 │ ← Always provide escape
│                                     │
└─────────────────────────────────────┘
```

### Trigger Points (Gentle Nudging)
- **After 5 successful suggestions** - "Love these suggestions? Save your favorites!"
- **When accessing favorites** - "Premium unlocks unlimited saves"
- **Settings screen** - Subtle upgrade option, never pushy

---

## 🔄 **State Management Structure**

### Screen State Patterns
```swift
// Home Screen States
enum HomeState {
    case loading        // Initial app launch
    case suggestion(Meal) // Normal state with meal
    case error(String)    // Network/API error
    case empty           // Fallback state
}

// Navigation State
enum NavigationState {
    case home
    case favorites  
    case settings
    case recipe(Meal)
}
```

### Data Flow Architecture
```
User Action → ViewModel → Service Layer → Supabase → UI Update
     ↑                                                    ↓
     ←────────── Completion/Error Handling ←──────────────
```

### Loading State Choreography
1. **User taps "Get New Suggestion"**
2. **Button shows loading indicator** (immediate feedback)
3. **Card content shimmers** (skeleton loading)
4. **New content slides in** (success state)
5. **Button returns to normal** (ready for next action)

---

## 🎯 **Error Handling Structure**

### Error State Philosophy: "Never Block, Always Guide"
Every error state provides a clear path forward.

### Error Categories & Responses
```swift
// Network Errors
"Unable to load new suggestion" 
→ [Try Again] button + cached fallback suggestion

// Premium Feature Access
"Save to favorites with Premium"
→ [Learn More] + [Maybe Later] options

// System Errors  
"Something went wrong"
→ [Contact Support] + [Restart App] options
```

### Error State Layouts
- **Toast notifications** for non-critical errors
- **Inline messages** for form validation
- **Full-screen states** only for critical failures
- **Always provide recovery action**

---

## 📊 **Performance Structure**

### Loading Time Budgets
```
App Launch: < 2 seconds to first screen
New Suggestion: < 1 second with caching
Recipe Detail: < 0.5 seconds (cached images)
Navigation: < 0.3 seconds (instant feel)
```

### Caching Strategy
- **Suggestion prefetching** - Load 2-3 suggestions ahead
- **Image preloading** - Cache hero images for smooth experience  
- **Offline graceful degradation** - Show cached content when network fails

### Memory Management
- **Lazy loading** for non-visible content
- **Image optimization** - WebP format, appropriate sizes
- **View cleanup** - Proper SwiftUI memory management

---

## 🔐 **Privacy & Security Structure**

### Data Minimization
- **No tracking** without explicit consent
- **Local preferences** stored in UserDefaults
- **Cloud sync** only for premium features with user approval

### User Control
- **Clear data usage** explanations
- **Easy account deletion** 
- **Transparent privacy policy**

---

## ✅ **Quality Assurance Structure**

### Testing Strategy
```swift
// Unit Tests - Business Logic
HomeViewModelTests
SuggestionServiceTests
UserPreferencesTests

// UI Tests - Critical User Flows
SuggestionFlowTests
NavigationTests  
PremiumUpgradeTests
```

### Performance Monitoring
- **App launch time** tracking
- **API response time** monitoring
- **Crash reporting** with user privacy
- **User satisfaction** metrics (App Store ratings)

---

## 🎨 **Accessibility Structure**

### VoiceOver Support
```swift
// All interactive elements have labels
Button("Get New Suggestion")
    .accessibilityLabel("Generate a new meal suggestion")
    .accessibilityHint("Finds a different meal recommendation for you")

// Images have meaningful descriptions  
AsyncImage(url: meal.imageURL)
    .accessibilityLabel("Photo of \(meal.title)")
```

### Dynamic Type Support
- **All text scales** with user preferences
- **Layout adapts** to larger text sizes
- **Maintain usability** at accessibility sizes

### Motor Accessibility
- **44pt minimum** touch targets
- **Adequate spacing** between interactive elements
- **No required complex gestures**

---

## 📱 **Platform Integration Structure**

### iOS Feature Integration
```swift
// Shortcuts (Future Phase)
"Hey Siri, what should I eat?"

// Widgets (Future Phase)  
Home screen widget with daily suggestion

// Handoff (Future Phase)
Continue recipe on iPad/Mac
```

### External Integrations
- **Delivery services** - Deep links to Uber Eats, DoorDash
- **Calendar integration** - Add cooking time to calendar
- **Health app** - Nutrition data sharing (with permission)

---

## 🚀 **Success Metrics Structure**

### User Experience Metrics (iPhone 5s Quality)
- **Time to first suggestion**: < 3 seconds
- **Task completion rate**: > 90%
- **User returns next day**: > 60%
- **App Store rating**: > 4.5 stars

### Business Metrics
- **Premium conversion**: 3-7% target
- **Daily active users**: Growing week-over-week
- **Session duration**: 1-3 minutes (efficient, not addictive)

### Technical Metrics
- **Crash-free rate**: > 99.5%
- **API response time**: P95 < 1 second
- **Memory usage**: < 100MB typical
- **Battery impact**: Minimal (Background App Refresh compliant)

---

**Remember**: This structure serves our core mission - create an iPhone 5s-quality experience where the interface disappears and users effortlessly discover what to eat. Every structural decision should pass the "invisible interface" test - does this help or hinder the user's primary goal? 🍽️📱✨
