# MealAdvisor Design Rulebook

*Last Updated: September 21, 2025*  
*Project: MealAdvisor iOS App - "What Should I Eat Today?" Utility*

---

## 🎨 **Design Philosophy**

### Visual Personality: Clean & Minimal with Warm Touches
- **iOS-native feel** with warm brand color accents
- **Generous white space** for breathing room and focus
- **Subtle, purposeful animations** that enhance UX without distraction
- **Trustworthy and approachable** - users should feel confident in suggestions
- **Food-focused** - let the meal imagery be the hero

### Design Principles
1. **Accessibility First** - Every design decision considers all users
2. **iOS HIG Compliance** - Native patterns users expect
3. **Performance Aware** - Beautiful but fast-loading
4. **Content Hierarchy** - Clear visual priorities guide user attention

---

## 🌈 **Color System**

### Primary Brand Colors

#### Warm Orange (Primary)
```swift
Color("PrimaryOrange")
    Light Mode: #FF6B35 // Appetizing, trustworthy, food-friendly
    Dark Mode: #FF7A47   // Slightly lighter for dark backgrounds
```

#### Fresh Green (Accent)
```swift
Color("AccentGreen")
    Light Mode: #34C759  // iOS system green (familiar)
    Dark Mode: #30D158   // iOS dark mode green
```

### Color System Structure: Hybrid Approach

#### iOS Semantic Colors (Automatic Dark Mode)
```swift
// Use for all text and backgrounds
Color(.systemBackground)        // Main backgrounds
Color(.secondarySystemBackground) // Card backgrounds  
Color(.systemGroupedBackground) // Grouped list backgrounds
Color(.label)                   // Primary text
Color(.secondaryLabel)          // Secondary text
Color(.tertiaryLabel)          // Tertiary text
Color(.quaternaryLabel)        // Quaternary text/placeholders
Color(.separator)              // Divider lines
```

#### Custom Brand Usage
- **Primary buttons and CTAs**: PrimaryOrange
- **Accent elements**: AccentGreen (favorites, success states)
- **Tab bar tint**: PrimaryOrange
- **Progress indicators**: PrimaryOrange

#### Semantic State Colors (iOS System)
```swift
Color(.systemRed)      // Error states, destructive actions
Color(.systemYellow)   // Warning states
Color(.systemGreen)    // Success states (or AccentGreen)
Color(.systemBlue)     // Links, informational
```

### Dark Mode Compliance
- **All custom colors** must have dark mode variants
- **Test all components** in both light and dark modes
- **Use iOS semantic colors** for automatic adaptation
- **Contrast ratios**: WCAG AA compliance (4.5:1 normal, 3:1 large text)

---

## ✍️ **Typography System**

### Font Strategy: SF Pro (iOS System Font Only)

```swift
// Typography Scale - iOS Standard
.largeTitle     // SF Pro Display, 34pt - Main screen titles
.title          // SF Pro Display, 28pt - Section headers  
.title2         // SF Pro Text, 22pt - Meal titles, important headers
.title3         // SF Pro Text, 20pt - Card titles
.headline       // SF Pro Text, 17pt - Emphasized body text
.body           // SF Pro Text, 17pt - Primary body text
.callout        // SF Pro Text, 16pt - Secondary body text
.subheadline    // SF Pro Text, 15pt - Tertiary text
.footnote       // SF Pro Text, 13pt - Small details
.caption        // SF Pro Text, 12pt - Timestamps, metadata
.caption2       // SF Pro Text, 11pt - Fine print
```

### Typography Usage Guidelines

#### Meal Suggestion Cards
- **Meal Title**: `.title2` (22pt, Medium weight)
- **Description**: `.body` (17pt, Regular weight)
- **Prep Time/Difficulty**: `.caption` (12pt, Medium weight)
- **Nutritional Info**: `.footnote` (13pt, Regular weight)

#### Navigation & Headers
- **Navigation Titles**: `.largeTitle` (34pt, Bold weight)
- **Section Headers**: `.title` (28pt, Bold weight)
- **Card Section Titles**: `.headline` (17pt, Semibold weight)

#### Buttons & Interactive Elements
- **Primary Button Text**: `.body` (17pt, Medium weight)
- **Secondary Button Text**: `.callout` (16pt, Medium weight)
- **Tab Bar Labels**: `.caption2` (11pt, Medium weight)

### Dynamic Type Support
- **All text must scale** with user's preferred text size
- **Test at largest accessibility sizes** (AX1, AX2, AX3, AX4, AX5)
- **Maintain layout integrity** at all sizes
- **Consider line height adjustments** for readability

---

## 🖼️ **Visual Elements**

### Food Photography Standards

#### Style: Bright, Clean, Minimalist
- **Apple-style food photography** (clean backgrounds, natural lighting)
- **High quality, appetizing** but not overly stylized
- **Focus on the food** with minimal props
- **Consistent lighting** across all images

#### Technical Specifications
- **Aspect Ratio**: 16:9 for hero images, 1:1 for thumbnails
- **Resolution**: Minimum 1080px width for hero images
- **Format**: WebP preferred, JPEG fallback
- **Compression**: Optimized for mobile (< 200KB per image)
- **Background**: Clean, neutral backgrounds preferred

#### Image Loading Strategy

##### Skeleton/Shimmer Style
```swift
// Shimmer placeholder
Rectangle()
    .fill(Color(.systemGray5)) // Auto dark mode (.systemGray4 in dark)
    .cornerRadius(16) // Match content corner radius
    .shimmer(duration: 1.5) // Continuous loop animation
```

##### Placeholder Strategy
```swift
// Loading state
RoundedRectangle(cornerRadius: 16)
    .fill(Color(.systemGray6)) // Light mode, .systemGray5 in dark
    .aspectRatio(16/9, contentMode: .fit) // Same aspect ratio as final image
    .overlay(
        Image(systemName: "photo")
            .foregroundColor(Color("PrimaryOrange"))
            .font(.title)
    )
```

##### Image Loading States
```swift
// Success: Smooth fade-in transition
AsyncImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
} placeholder: {
    shimmerPlaceholder
}

// Error: Fallback with category icon
Image(systemName: "fork.knife") // or "cup.and.saucer" for drinks
    .foregroundColor(Color("PrimaryOrange"))
    .font(.title)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGray6))
```

### Icons: SF Symbols Only

#### Icon Strategy
- **Use Apple's SF Symbols exclusively** - no custom icons
- **Consistent weight**: Medium or Semibold throughout app
- **No emoji or custom graphics** for UI elements
- **Semantic meaning** - icons should be universally understood

#### Core App Icons
```swift
// Tab Bar
"house.fill"           // Home
"heart.fill"           // Favorites  
"gearshape.fill"       // Settings

// Common Actions
"arrow.clockwise"      // Refresh/New suggestion
"bookmark.fill"        // Save recipe
"square.and.arrow.up"  // Share
"xmark"               // Close/Cancel
"chevron.right"       // Navigation forward
"plus"                // Add/Create
"minus"               // Remove
```

---

## 🧩 **Component Design System**

### Card Design: Clean Cards with Subtle Shadows

#### Suggestion Cards (Primary)
```swift
// Styling specifications
.background(Color(.systemBackground))
.cornerRadius(16) // iOS standard large corner radius
.shadow(color: Color(.black).opacity(0.1), radius: 8, x: 0, y: 2)
.padding(.horizontal, 16) // Screen margin
```

**Specifications**:
- **Size**: Full width minus 32pt margins (16pt each side)
- **Height**: Variable based on content (minimum 200pt)
- **Corner Radius**: 16pt (iOS large radius)
- **Shadow**: 2pt Y offset, 8pt blur, 10% black opacity
- **Internal Padding**: 16pt all sides
- **Background**: `.systemBackground` (automatic dark mode)

#### Secondary Cards (Settings, Lists)
```swift
// Lighter styling for less prominent cards
.background(Color(.secondarySystemBackground))
.cornerRadius(12) // Medium corner radius
.shadow(color: Color(.black).opacity(0.05), radius: 4, x: 0, y: 1)
```

### Button System

#### Primary Buttons (CTAs)
```swift
// Main action buttons
.frame(height: 50)
.background(Color("PrimaryOrange"))
.foregroundColor(.white)
.font(.body.weight(.medium))
.cornerRadius(12)
```

**Specifications**:
- **Height**: 50pt (comfortable touch target)
- **Background**: PrimaryOrange brand color
- **Text**: White, SF Pro Text Medium 17pt
- **Corner Radius**: 12pt (medium radius)
- **Minimum Width**: 120pt
- **Touch Target**: Minimum 44x44pt (iOS requirement)

#### Secondary Buttons (Outline)
```swift
// Less prominent actions
.frame(height: 44)
.background(Color.clear)
.foregroundColor(Color("PrimaryOrange"))
.font(.callout.weight(.medium))
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color("PrimaryOrange"), lineWidth: 1.5)
)
```

#### Text Buttons (Minimal)
```swift
// Least prominent actions
.foregroundColor(Color("PrimaryOrange"))
.font(.body.weight(.medium))
```

### Loading States

#### Progress Indicators
```swift
// Circular: For meal suggestion loading
ProgressView()
    .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryOrange")))
    .scaleEffect(1.2) // Slightly larger for better visibility

// Linear: For image loading within cards  
ProgressView(value: loadingProgress, total: 1.0)
    .progressViewStyle(LinearProgressViewStyle(tint: Color("PrimaryOrange")))
```

#### Empty States
```swift
// No meal suggestions yet
VStack(spacing: 16) {
    Image(systemName: "fork.knife")
        .font(.system(size: 48))
        .foregroundColor(.secondaryLabel)
    
    Text("No suggestions yet")
        .font(.headline)
        .foregroundColor(.secondaryLabel)
    
    Text("Tap the button above to get your first meal suggestion")
        .font(.body)
        .foregroundColor(.tertiaryLabel)
        .multilineTextAlignment(.center)
}
```

---

## 📐 **Layout & Spacing System**

### Spacing Scale (Multiples of 8pt)
```swift
// Consistent spacing throughout app
let cardSpacing: CGFloat = 16        // Between cards
let sectionSpacing: CGFloat = 24     // Between sections  
let screenMargin: CGFloat = 16       // Screen edges
let cardPadding: CGFloat = 16        // Card internal padding
let buttonPadding = (horizontal: 16, vertical: 12) // Button internal spacing
```

### Layout Guidelines

#### Component Spacing Rules
- **Between cards**: 16pt vertical spacing
- **Between sections**: 24pt vertical spacing
- **Card internal padding**: 16pt all sides
- **Button internal padding**: 16pt horizontal, 12pt vertical

#### Padding vs Margin Convention
- **Padding**: Internal spacing within components
- **Margin**: External spacing between components  
- **Screen edges**: Always 16pt margin from safe area

#### Touch Targets
- **Minimum Size**: 44x44pt (iOS accessibility requirement)
- **Recommended**: 48x48pt for primary actions
- **Spacing**: 8pt minimum between adjacent touch targets

#### Component Spacing Examples
```swift
// Vertical spacing within cards
VStack(spacing: 12) {
    // Meal title
    // Description  
    // Metadata (time, difficulty)
}

// Horizontal button groups
HStack(spacing: 16) {
    // Primary button
    // Secondary button
}

// Screen layout
VStack(spacing: sectionSpacing) {
    // Header section
    // Content cards
    // Action buttons
}
.padding(.horizontal, screenMargin)
```

---

## 🎬 **Animation & Motion**

### Animation Standards

#### Duration Guidelines
```swift
// Standard iOS durations
let standardTransition: TimeInterval = 0.3    // Default transitions
let quickInteraction: TimeInterval = 0.15     // Button taps, small state changes
let modalPresentation: TimeInterval = 0.4     // Sheet presentations (iOS standard)
```

#### Animation Types
- **Spring animations** for interactive elements (buttons, cards)
- **Ease curves** for page transitions and loading states
- **Reduce Motion support**: Replace animations with simple opacity/scale changes when enabled

#### Common Animations
```swift
// Card Appearance
.transition(.asymmetric(
    insertion: .scale(scale: 0.95).combined(with: .opacity),
    removal: .opacity
))
.animation(.spring(dampingFraction: 0.8, duration: standardTransition))

// Button Press Feedback
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.easeOut(duration: quickInteraction))

// Sheet Presentation
.animation(.easeInOut(duration: modalPresentation))
```

#### Reduce Motion Support
```swift
// Respect accessibility preferences
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditional animations
.animation(reduceMotion ? .none : .spring())
```

---

## ♿ **Accessibility Standards**

### Must-Have Features

#### VoiceOver Support
```swift
// All interactive elements need labels
Button("Get New Suggestion") { }
    .accessibilityLabel("Get a new meal suggestion")
    .accessibilityHint("Generates a new meal recommendation")

Image("pasta-dish")
    .accessibilityLabel("Creamy pasta with herbs")
```

#### Dynamic Type Support
- **All text scales** with user preferences
- **Layout adapts** to larger text sizes
- **Maintain usability** at accessibility sizes (AX1-AX5)
- **Test regularly** with largest text sizes

#### Color & Contrast
- **Contrast Ratios**: Minimum 4.5:1 for normal text, 3:1 for large text
- **Don't rely on color alone** for important information
- **Test with color blindness simulators**

#### Motor Accessibility
- **44pt minimum touch targets**
- **Adequate spacing** between interactive elements
- **Support for Switch Control**
- **No required gestures** that can't be done with assistive touch

---

## 🌙 **Dark Mode Guidelines**

### Implementation Strategy
```swift
// Color definitions with automatic dark mode
Color("PrimaryOrange")
    // Light: #FF6B35, Dark: #FF7A47

// Use iOS semantic colors for automatic adaptation
Color(.systemBackground)
Color(.label)
Color(.secondarySystemBackground)
```

### Dark Mode Considerations
- **Test all screens** in both light and dark modes
- **Images may need variants** for optimal contrast
- **Brand colors adjusted** for dark backgrounds
- **Shadows less prominent** in dark mode
- **Consider OLED displays** (true black backgrounds)

---

## 📱 **Platform-Specific Guidelines**

### iOS Navigation Patterns

#### Tab Bar (Primary Navigation)
```swift
// Standard iOS tab bar
TabView {
    HomeView().tabItem {
        Image(systemName: "house.fill")
        Text("Home")
    }
    FavoritesView().tabItem {
        Image(systemName: "heart.fill") 
        Text("Favorites")
    }
    SettingsView().tabItem {
        Image(systemName: "gearshape.fill")
        Text("Settings")
    }
}
.accentColor(Color("PrimaryOrange"))
```

#### Navigation Bar
- **Standard iOS navigation** with back buttons
- **Large titles** where appropriate
- **Toolbar buttons** for secondary actions
- **Sheet presentations** for modal content

#### Modal Presentations
```swift
// iOS-standard sheet presentations
.sheet(isPresented: $showSettings) {
    SettingsView()
}

// Full screen for immersive content
.fullScreenCover(isPresented: $showRecipe) {
    RecipeDetailView()
}
```

### Haptic Feedback
```swift
// Provide tactile feedback for interactions
let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
let selectionFeedback = UISelectionFeedbackGenerator()

// Use sparingly and meaningfully
Button("Save Recipe") {
    impactFeedback.impactOccurred()
    // Save action
}
```

---

## 🎯 **Error & Empty States**

### Error State Design

#### Toast Notifications (Non-Critical)
```swift
// Toast styling - bottom of screen
VStack {
    Spacer()
    
    HStack {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.white)
        
        Text("Unable to load suggestion. Please try again.")
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(Color(.systemRed).opacity(0.9))
    .cornerRadius(12)
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
}
```

#### Alert Dialogs (Critical Errors)
```swift
// Use iOS standard Alert - no custom styling needed
.alert("Connection Error", isPresented: $showAlert) {
    Button("Try Again") { /* retry action */ }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("Please check your internet connection and try again.")
}
```

#### Inline Error Text
```swift
// Form field errors
HStack {
    Image(systemName: "exclamationmark.triangle.fill")
        .foregroundColor(.systemRed)
        .font(.caption)
    
    Text("Please select at least one dietary preference")
        .font(.system(size: 14))
        .foregroundColor(.systemRed)
}
```

---

## 🔍 **Quality Checklist**

### Pre-Release Design Review

#### Visual Consistency
- [ ] All colors use defined design tokens
- [ ] Typography follows established scale
- [ ] Spacing uses 8pt grid system
- [ ] Corner radius consistent (8pt, 12pt, 16pt)
- [ ] Icons are SF Symbols with consistent weight

#### iOS Compliance
- [ ] Follows Apple Human Interface Guidelines
- [ ] Native navigation patterns used
- [ ] Proper use of iOS semantic colors
- [ ] Standard component behaviors maintained

#### Accessibility
- [ ] VoiceOver labels on all interactive elements
- [ ] 44pt minimum touch targets
- [ ] Dynamic Type support tested
- [ ] Color contrast ratios verified
- [ ] Reduce Motion preferences respected

#### Dark Mode
- [ ] All screens tested in dark mode
- [ ] Custom colors have dark variants
- [ ] Sufficient contrast in both modes
- [ ] Images work well in both modes

---

## 📋 **Quick Reference Summary**

```swift
// Animation Durations
let standardTransition: TimeInterval = 0.3
let quickInteraction: TimeInterval = 0.15
let modalPresentation: TimeInterval = 0.4

// Spacing System
let cardSpacing: CGFloat = 16
let sectionSpacing: CGFloat = 24
let screenMargin: CGFloat = 16
let cardPadding: CGFloat = 16

// Loading Colors
let shimmerColor = Color(.systemGray5) // Auto dark mode
let progressTint = Color("PrimaryOrange")

// Error Colors
let errorText = Color(.systemRed)
let errorBackground = Color(.systemRed).opacity(0.9)
```

---

**Remember**: This design system serves our core mission - create a trustworthy, approachable meal suggestion app that feels native to iOS while maintaining our warm, food-friendly brand personality. When in doubt, default to iOS standards and add brand touches thoughtfully. 🍽️✨
