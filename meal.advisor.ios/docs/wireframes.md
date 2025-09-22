# MealAdvisor Wireframes

*Last Updated: September 21, 2025*  
*Project: MealAdvisor iOS App - "What Should I Eat Today?" Utility*

---

## 📱 **Device Specifications**

**Target Device**: iPhone 14/15 (6.1" screen)  
**Screen Dimensions**: 390x844 points  
**Safe Area**: Top 47pt, Bottom 34pt  
**Design Grid**: 8pt base unit, 16pt margins  

---

## 🏠 **Home Screen - Primary Interface**

### Layout Dimensions
- **Screen Width**: 390pt
- **Content Width**: 358pt (390 - 32pt margins)
- **Card Height**: ~400pt (60% of available space)
- **Button Height**: 50pt
- **Spacing**: 16pt between major elements

```
┌────────────────────────────────────────────────────────────────────────────────┐ 390pt
│  ┌─ Safe Area ─┐                                                               │
│  │ 9:41 AM    ◯ ◯ ◯                                                  100% ⚡   │ 47pt
│  └─────────────┘                                                               │
│                                                                                │
│  ┌─ 16pt margin ─┐                                              ┌─ 16pt ─┐    │
│  │                                                              │         │    │
│  │   Good evening! What's for dinner? 🌅                       │         │    │ 32pt
│  │   ↑ Dynamic greeting (SF Pro Text, 20pt, Medium)            │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │ 16pt
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │                                                      │  │         │    │
│  │   │                                                      │  │         │    │
│  │   │           [Hero Food Image 16:9]                    │  │         │    │ 200pt
│  │   │              358x200pt                              │  │         │    │
│  │   │         Creamy Tuscan Chicken                       │  │         │    │
│  │   │                                                      │  │         │    │
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │                                                              │         │    │
│  │   Creamy Tuscan Chicken                                      │         │    │ 28pt
│  │   ↑ Meal title (SF Pro Display, 22pt, Bold, 2 lines max)    │         │    │
│  │                                                              │         │    │
│  │   ⏱️ 25 min    🔥 Easy    🇮🇹 Italian                        │         │    │ 24pt
│  │   ↑ Metadata badges (SF Pro Text, 14pt, Medium)             │         │    │
│  │                                                              │         │    │
│  │   A rich, creamy chicken dish with sun-dried tomatoes       │         │    │ 40pt
│  │   and fresh spinach. Perfect for a cozy dinner at home.     │         │    │
│  │   ↑ Description (SF Pro Text, 16pt, Regular, 2 lines max)   │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │ 24pt
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │               Get New Suggestion                     │  │         │    │ 50pt
│  │   │          ↑ Primary CTA (SF Pro Text, 17pt, Medium)   │  │         │    │
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │ 16pt
│  │   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │         │    │
│  │   │ See Recipe  │ │    Save     │ │    Order    │          │         │    │ 44pt
│  │   │     ↑       │ │      ↑      │ │      ↑      │          │         │    │
│  │   │ Secondary   │ │  Premium    │ │  External   │          │         │    │
│  │   │   Action    │ │   Feature   │ │    Link     │          │         │    │
│  │   └─────────────┘ └─────────────┘ └─────────────┘          │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │
│  └──────────────────────────────────────────────────────────────┘         │    │
│                                                                            │    │
│  ┌─ Tab Bar ─────────────────────────────────────────────────────────────┐ │    │
│  │                                                                        │ │    │ 83pt
│  │    🏠 Home         ❤️ Favorites         ⚙️ Settings                   │ │    │
│  │  ↑ Selected    ↑ Available (Premium)  ↑ Available                    │ │    │
│  │                                                                        │ │    │
│  └────────────────────────────────────────────────────────────────────────┘ │    │
│  ┌─ Safe Area Bottom ─┐                                                       │
│  │                    │                                                       │ 34pt
│  └────────────────────┘                                                       │
└────────────────────────────────────────────────────────────────────────────────┘
```

### Component Specifications

#### Hero Suggestion Card
```swift
// Card container
.frame(width: 358, height: ~400)
.background(Color(.systemBackground))
.cornerRadius(16)
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

// Internal layout
VStack(spacing: 12) {
    AsyncImage(url: meal.imageURL)
        .aspectRatio(16/9, contentMode: .fill)
        .frame(height: 200)
        .clipped()
        .cornerRadius(12)
    
    VStack(alignment: .leading, spacing: 8) {
        Text(meal.title)
            .font(.title2.bold())
            .lineLimit(2)
        
        HStack(spacing: 12) {
            Badge("⏱️ \(meal.prepTime)")
            Badge("🔥 \(meal.difficulty)")  
            Badge("🇮🇹 \(meal.cuisine)")
        }
        
        Text(meal.description)
            .font(.body)
            .foregroundColor(.secondary)
            .lineLimit(2)
    }
}
.padding(16)
```

#### Primary Action Button
```swift
Button("Get New Suggestion") { }
    .frame(height: 50)
    .frame(maxWidth: .infinity)
    .background(Color("PrimaryOrange"))
    .foregroundColor(.white)
    .font(.body.weight(.medium))
    .cornerRadius(12)
```

#### Secondary Action Buttons
```swift
HStack(spacing: 16) {
    Button("See Recipe") { }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(Color.clear)
        .foregroundColor(Color("PrimaryOrange"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("PrimaryOrange"), lineWidth: 1.5)
        )
    
    Button("Save") { }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color("PrimaryOrange"))
    
    Button("Order") { }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color("PrimaryOrange"))
}
```

---

## ❤️ **Favorites Screen - Collection Interface**

### Grid Layout Specifications
- **Columns**: 2 (fixed)
- **Item Width**: 171pt each (358 - 16pt spacing / 2)
- **Item Height**: 200pt (square + text)
- **Grid Spacing**: 16pt horizontal, 16pt vertical

```
┌────────────────────────────────────────────────────────────────────────────────┐
│  ┌─ Safe Area ─┐                                                               │
│  │ 9:41 AM    ◯ ◯ ◯                                                  100% ⚡   │ 47pt
│  └─────────────┘                                                               │
│                                                                                │
│  ┌─ Navigation Bar ─────────────────────────────────────────────────────────┐  │
│  │                                                                          │  │ 44pt
│  │                        Favorites                                         │  │
│  │                     ↑ Large Title                                       │  │
│  │                                                                          │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                │
│  ┌─ 16pt margin ─┐                                              ┌─ 16pt ─┐    │
│  │                                                              │         │    │
│  │   ┌─────────────────────────┐   ┌─────────────────────────┐  │         │    │
│  │   │                         │   │                         │  │         │    │
│  │   │     [Food Image]        │   │     [Food Image]        │  │         │    │ 140pt
│  │   │       171x140pt         │   │       171x140pt         │  │         │    │
│  │   │                         │   │                         │  │         │    │
│  │   └─────────────────────────┘   └─────────────────────────┘  │         │    │
│  │   Creamy Tuscan Chicken         Spicy Beef Tacos            │         │    │ 20pt
│  │   ⏱️ 25 min  🔥 Easy             ⏱️ 15 min  🔥 Medium         │         │    │ 16pt
│  │                                                              │         │    │
│  │                                                              │         │    │ 16pt
│  │   ┌─────────────────────────┐   ┌─────────────────────────┐  │         │    │
│  │   │                         │   │                         │  │         │    │
│  │   │     [Food Image]        │   │     [Food Image]        │  │         │    │ 140pt
│  │   │       171x140pt         │   │       171x140pt         │  │         │    │
│  │   │                         │   │                         │  │         │    │
│  │   └─────────────────────────┘   └─────────────────────────┘  │         │    │
│  │   Greek Quinoa Salad            Thai Green Curry            │         │    │ 20pt
│  │   ⏱️ 10 min  🔥 Easy             ⏱️ 30 min  🔥 Hard          │         │    │ 16pt
│  │                                                              │         │    │
│  │                                                              │         │    │ 16pt
│  │   ┌─────────────────────────┐   ┌─────────────────────────┐  │         │    │
│  │   │                         │   │           ┌─┐           │  │         │    │
│  │   │     [Food Image]        │   │           │+│           │  │         │    │ 140pt
│  │   │       171x140pt         │   │     Add More Meals      │  │         │    │
│  │   │                         │   │           └─┘           │  │         │    │
│  │   └─────────────────────────┘   └─────────────────────────┘  │         │    │
│  │   Lemon Herb Salmon             ↑ Empty state CTA          │         │    │ 20pt
│  │   ⏱️ 20 min  🔥 Medium                                       │         │    │ 16pt
│  │                                                              │         │    │
│  │                                                              │         │    │
│  └──────────────────────────────────────────────────────────────┘         │    │
│                                                                            │    │
│  ┌─ Tab Bar ─────────────────────────────────────────────────────────────┐ │    │
│  │                                                                        │ │    │ 83pt
│  │    🏠 Home         ❤️ Favorites         ⚙️ Settings                   │ │    │
│  │   Available      ↑ Selected           Available                       │ │    │
│  │                                                                        │ │    │
│  └────────────────────────────────────────────────────────────────────────┘ │    │
│  ┌─ Safe Area Bottom ─┐                                                       │
│  │                    │                                                       │ 34pt
│  └────────────────────┘                                                       │
└────────────────────────────────────────────────────────────────────────────────┘
```

### Empty State (No Favorites Yet)
```
┌────────────────────────────────────────────────────────────────────────────────┐
│                                                                                │
│  ┌─ 16pt margin ─┐                                              ┌─ 16pt ─┐    │
│  │                                                              │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │
│  │                           🍽️                                 │         │    │ 48pt
│  │                    ↑ SF Symbol icon                          │         │    │
│  │                                                              │         │    │
│  │                    No favorites yet                          │         │    │ 24pt
│  │               ↑ Headline (SF Pro, 20pt, Bold)               │         │    │
│  │                                                              │         │    │
│  │           Start exploring meal suggestions to                │         │    │ 40pt
│  │              save your favorite recipes                      │         │    │
│  │          ↑ Body text (SF Pro, 16pt, Secondary)              │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │ 24pt
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │              Discover Meals                          │  │         │    │ 50pt
│  │   │           ↑ Primary CTA Button                       │  │         │    │
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │
│  └──────────────────────────────────────────────────────────────┘         │    │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ **Settings Screen - Configuration Interface**

### Grouped List Layout (iOS Standard)
- **Section Headers**: 28pt height
- **Row Height**: 44pt minimum
- **Group Spacing**: 35pt between sections

```
┌────────────────────────────────────────────────────────────────────────────────┐
│  ┌─ Safe Area ─┐                                                               │
│  │ 9:41 AM    ◯ ◯ ◯                                                  100% ⚡   │ 47pt
│  └─────────────┘                                                               │
│                                                                                │
│  ┌─ Navigation Bar ─────────────────────────────────────────────────────────┐  │
│  │                                                                          │  │ 44pt
│  │                        Settings                                          │  │
│  │                     ↑ Large Title                                       │  │
│  │                                                                          │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                │
│  ┌─ 16pt margin ─┐                                              ┌─ 16pt ─┐    │
│  │                                                              │         │    │
│  │   PREFERENCES                                                │         │    │ 28pt
│  │   ↑ Section header (SF Pro, 13pt, Uppercase)                │         │    │
│  │                                                              │         │    │
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │  🚫  Dietary Restrictions              3 selected  >  │  │         │    │ 44pt
│  │   ├──────────────────────────────────────────────────────┤  │         │    │
│  │   │  ⏱️  Cooking Time Available           30 minutes   >  │  │         │    │ 44pt
│  │   ├──────────────────────────────────────────────────────┤  │         │    │
│  │   │  🌍  Cuisine Preferences              All cuisines >  │  │         │    │ 44pt
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │   ↑ Grouped list with disclosure indicators                 │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │ 35pt
│  │   ACCOUNT                                                    │         │    │ 28pt
│  │                                                              │         │    │
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │  👤  Sign in with Apple                              │  │         │    │ 44pt
│  │   ├──────────────────────────────────────────────────────┤  │         │    │
│  │   │  💎  Premium Subscription              Not active  >  │  │         │    │ 44pt
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │ 35pt
│  │   ABOUT                                                      │         │    │ 28pt
│  │                                                              │         │    │
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │  📄  Privacy Policy                                >  │  │         │    │ 44pt
│  │   ├──────────────────────────────────────────────────────┤  │         │    │
│  │   │  📋  Terms of Service                             >  │  │         │    │ 44pt
│  │   ├──────────────────────────────────────────────────────┤  │         │    │
│  │   │  ℹ️   App Version                               1.0.0  │  │         │    │ 44pt
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │                                                              │         │    │
│  │                                                              │         │    │
│  └──────────────────────────────────────────────────────────────┘         │    │
│                                                                            │    │
│  ┌─ Tab Bar ─────────────────────────────────────────────────────────────┐ │    │
│  │                                                                        │ │    │ 83pt
│  │    🏠 Home         ❤️ Favorites         ⚙️ Settings                   │ │    │
│  │   Available        Available         ↑ Selected                       │ │    │
│  │                                                                        │ │    │
│  └────────────────────────────────────────────────────────────────────────┘ │    │
│  ┌─ Safe Area Bottom ─┐                                                       │
│  │                    │                                                       │ 34pt
│  └────────────────────┘                                                       │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📄 **Recipe Detail Screen - Content Modal**

### Full-Screen Modal Presentation
- **Navigation Bar**: 44pt with close button
- **Content Scroll**: Full height minus nav and safe areas
- **Image Height**: 250pt (immersive but not overwhelming)

```
┌────────────────────────────────────────────────────────────────────────────────┐
│  ┌─ Safe Area ─┐                                                               │
│  │ 9:41 AM    ◯ ◯ ◯                                                  100% ⚡   │ 47pt
│  └─────────────┘                                                               │
│                                                                                │
│  ┌─ Navigation Bar ─────────────────────────────────────────────────────────┐  │
│  │                                                                          │  │ 44pt
│  │  ✕ Close                                            Share    Save        │  │
│  │  ↑ Dismiss                                         ↑ Actions            │  │
│  │                                                                          │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                │
│  ┌─ Scrollable Content ─────────────────────────────────────────────────────┐  │
│  │                                                                          │  │
│  │  ┌────────────────────────────────────────────────────────────────────┐ │  │
│  │  │                                                                    │ │  │
│  │  │                   [Hero Food Image]                               │ │  │ 250pt
│  │  │                      390x250pt                                    │ │  │
│  │  │                  Full-width, immersive                            │ │  │
│  │  │                                                                    │ │  │
│  │  └────────────────────────────────────────────────────────────────────┘ │  │
│  │                                                                          │  │
│  │  ┌─ 16pt margin ─┐                                      ┌─ 16pt ─┐      │  │
│  │  │                                                      │         │      │  │
│  │  │   Creamy Tuscan Chicken                              │         │      │  │ 32pt
│  │  │   ↑ Recipe title (SF Pro Display, 28pt, Bold)       │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │   ⏱️ 25 min   🔥 Easy   👥 4 servings   🇮🇹 Italian   │         │      │  │ 24pt
│  │  │   ↑ Metadata badges (SF Pro Text, 14pt)             │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 16pt
│  │  │   A rich, creamy chicken dish featuring tender      │         │      │  │
│  │  │   chicken breast, sun-dried tomatoes, fresh         │         │      │  │ 60pt
│  │  │   spinach, and aromatic herbs in a luscious         │         │      │  │
│  │  │   cream sauce. Perfect for a cozy dinner.           │         │      │  │
│  │  │   ↑ Description (SF Pro Text, 16pt, Regular)        │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 24pt
│  │  │   Ingredients                                        │         │      │  │ 24pt
│  │  │   ↑ Section header (SF Pro Text, 20pt, Bold)        │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │   • 1 lb boneless, skinless chicken breast          │         │      │  │ 20pt
│  │  │   • 1 cup heavy cream                               │         │      │  │ 20pt
│  │  │   • 2 tbsp olive oil                                │         │      │  │ 20pt
│  │  │   • 3 cloves garlic, minced                         │         │      │  │ 20pt
│  │  │   • 1/2 cup sun-dried tomatoes, chopped             │         │      │  │ 20pt
│  │  │   • 2 cups fresh spinach                            │         │      │  │ 20pt
│  │  │   • 1/2 cup grated Parmesan cheese                  │         │      │  │ 20pt
│  │  │   • Salt and pepper to taste                        │         │      │  │ 20pt
│  │  │   ↑ Ingredient list (SF Pro Text, 16pt, Regular)    │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 24pt
│  │  │   Instructions                                       │         │      │  │ 24pt
│  │  │   ↑ Section header (SF Pro Text, 20pt, Bold)        │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │   1. Heat olive oil in a large skillet over         │         │      │  │
│  │  │      medium-high heat. Season chicken with          │         │      │  │ 40pt
│  │  │      salt and pepper.                               │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │   2. Add chicken to skillet and cook for 6-7        │         │      │  │
│  │  │      minutes on each side until golden brown        │         │      │  │ 40pt
│  │  │      and cooked through. Remove and set aside.      │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │   3. In the same skillet, add garlic and cook       │         │      │  │
│  │  │      for 1 minute until fragrant. Add sun-dried     │         │      │  │ 40pt
│  │  │      tomatoes and cook for 2 minutes.               │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │   4. Pour in heavy cream and bring to a simmer.     │         │      │  │
│  │  │      Add spinach and cook until wilted. Stir in     │         │      │  │ 40pt
│  │  │      Parmesan cheese until melted.                  │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │   5. Return chicken to skillet and simmer for       │         │      │  │
│  │  │      2-3 minutes until heated through. Serve        │         │      │  │ 40pt
│  │  │      immediately over pasta or rice.                │         │      │  │
│  │  │   ↑ Step-by-step instructions (SF Pro, 16pt)        │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 32pt
│  │  │   ┌──────────────────────────────────────────────┐  │         │      │  │
│  │  │   │               Start Cooking                  │  │         │      │  │ 50pt
│  │  │   │          ↑ Primary CTA Button                │  │         │      │  │
│  │  │   └──────────────────────────────────────────────┘  │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 32pt
│  │  └──────────────────────────────────────────────────────┘         │      │  │
│  │                                                                    │      │  │
│  └────────────────────────────────────────────────────────────────────┘      │  │
│  ┌─ Safe Area Bottom ─┐                                                       │
│  │                    │                                                       │ 34pt
│  └────────────────────┘                                                       │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## 💎 **Premium Paywall Modal**

### Sheet Presentation (Triggered Context)
- **Modal Height**: ~500pt (comfortable reading)
- **Content Centered**: Clear value proposition
- **Escape Route**: Always provide "Maybe Later"

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                                                                                │
│                                                                                │
│                                                                                │
│                                                                                │
│  ┌─ Modal Sheet ────────────────────────────────────────────────────────────┐  │
│  │                                                                          │  │
│  │  ┌─ Sheet Handle ─┐                                                      │  │ 20pt
│  │  │       ━━━      │                                                      │  │
│  │  └────────────────┘                                                      │  │
│  │                                                                          │  │
│  │  ┌─ 24pt margin ─┐                                      ┌─ 24pt ─┐      │  │
│  │  │                                                      │         │      │  │
│  │  │                         💎                           │         │      │  │ 48pt
│  │  │                  ↑ Premium icon                      │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │           Unlock Your Full Meal Experience          │         │      │  │ 32pt
│  │  │        ↑ Headline (SF Pro Display, 24pt, Bold)      │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │        Get the most out of your meal planning       │         │      │  │ 40pt
│  │  │         with unlimited saves and smart features     │         │      │  │
│  │  │       ↑ Subtitle (SF Pro Text, 16pt, Secondary)     │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 24pt
│  │  │   ✓ Save unlimited favorite meals                   │         │      │  │ 24pt
│  │  │   ✓ Advanced dietary and cuisine filters            │         │      │  │ 24pt
│  │  │   ✓ Weekly meal planning calendar                   │         │      │  │ 24pt
│  │  │   ✓ Smart shopping list generation                  │         │      │  │ 24pt
│  │  │   ✓ Nutrition tracking and insights                 │         │      │  │ 24pt
│  │  │   ↑ Feature list (SF Pro Text, 16pt, Regular)       │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 32pt
│  │  │   ┌──────────────────────────────────────────────┐  │         │      │  │
│  │  │   │         Start Free Trial - $4.99/mo         │  │         │      │  │ 50pt
│  │  │   │      ↑ Primary CTA (Clear, honest pricing)   │  │         │      │  │
│  │  │   └──────────────────────────────────────────────┘  │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │              Cancel anytime • No commitments        │         │      │  │ 16pt
│  │  │           ↑ Reassurance text (SF Pro, 13pt)         │         │      │  │
│  │  │                                                      │         │      │  │
│  │  │                                                      │         │      │  │ 24pt
│  │  │                   Maybe Later                        │         │      │  │ 20pt
│  │  │               ↑ Escape route (Text button)           │         │      │  │
│  │  │                                                      │         │      │  │
│  │  └──────────────────────────────────────────────────────┘         │      │  │
│  │                                                                    │      │  │
│  └────────────────────────────────────────────────────────────────────┘      │  │
│                                                                                │
│                                                                                │
│                                                                                │
│                                                                                │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 **Loading States & Transitions**

### Home Screen - New Suggestion Loading
```
┌────────────────────────────────────────────────────────────────────────────────┐
│  ┌─ During Loading Animation ─┐                                                │
│  │                                                                            │
│  │   Good evening! What's for dinner? 🌅                                     │
│  │                                                                            │
│  │   ┌──────────────────────────────────────────────────────┐                │
│  │   │                                                      │                │
│  │   │           [Shimmer Rectangle]                        │                │ 200pt
│  │   │              358x200pt                              │                │
│  │   │         ↑ Animated shimmer effect                   │                │
│  │   │           (.systemGray5 background)                 │                │
│  │   │                                                      │                │
│  │   └──────────────────────────────────────────────────────┘                │
│  │                                                                            │
│  │   [Shimmer Text Line - 200pt wide]                                        │ 22pt
│  │   ↑ Title placeholder                                                     │
│  │                                                                            │
│  │   [Shimmer] [Shimmer] [Shimmer]                                           │ 16pt
│  │   ↑ Badge placeholders                                                    │
│  │                                                                            │
│  │   [Shimmer Text Line - 300pt wide]                                        │ 16pt
│  │   [Shimmer Text Line - 250pt wide]                                        │ 16pt
│  │   ↑ Description placeholders                                              │
│  │                                                                            │
│  │   ┌──────────────────────────────────────────────────────┐                │
│  │   │          🔄 Loading new suggestion...                │                │ 50pt
│  │   │        ↑ Loading state with spinner                 │                │
│  │   └──────────────────────────────────────────────────────┘                │
│  │                                                                            │
│  │   [Disabled] [Disabled] [Disabled]                                        │
│  │   ↑ Secondary buttons disabled during loading                             │
│  │                                                                            │
│  └────────────────────────────────────────────────────────────────────────────┘
└────────────────────────────────────────────────────────────────────────────────┘
```

### Transition Animation Sequence
```
Phase 1 (0.0s - 0.2s): Current content fades out
Phase 2 (0.2s - 1.0s): Shimmer placeholders animate
Phase 3 (1.0s - 1.3s): New content slides in from right
Phase 4 (1.3s): Ready state - user can interact
```

---

## ❌ **Error States**

### Network Error (Home Screen)
```
┌────────────────────────────────────────────────────────────────────────────────┐
│                                                                                │
│   Good evening! What's for dinner? 🌅                                         │
│                                                                                │
│   ┌──────────────────────────────────────────────────────┐                    │
│   │                                                      │                    │
│   │                      📶❌                            │                    │ 200pt
│   │                ↑ No connection icon                  │                    │
│   │                                                      │                    │
│   │              Unable to load suggestion               │                    │
│   │           ↑ Clear, friendly error message            │                    │
│   │                                                      │                    │
│   │              Please check your connection            │                    │
│   │                   and try again                      │                    │
│   │                                                      │                    │
│   └──────────────────────────────────────────────────────┘                    │
│                                                                                │
│   Last suggestion shown: Creamy Tuscan Chicken                                │ 16pt
│   ↑ Fallback content (cached from previous session)                           │
│                                                                                │
│   ┌──────────────────────────────────────────────────────┐                    │
│   │                   Try Again                          │                    │ 50pt
│   │              ↑ Recovery action CTA                   │                    │
│   └──────────────────────────────────────────────────────┘                    │
│                                                                                │
│   [See Recipe]  [Save]  [Order]                                               │
│   ↑ Secondary actions still available for cached content                      │
│                                                                                │
└────────────────────────────────────────────────────────────────────────────────┘
```

### Empty Favorites (Premium Required)
```
┌────────────────────────────────────────────────────────────────────────────────┐
│                        Favorites                                               │
│                                                                                │
│                                                                                │
│                             💎                                                 │ 48pt
│                      ↑ Premium icon                                           │
│                                                                                │
│                    Save Your Favorites                                        │ 24pt
│               ↑ Headline (SF Pro, 20pt, Bold)                                 │
│                                                                                │
│           Premium lets you save unlimited meals                                │ 40pt
│              and build your personal cookbook                                  │
│          ↑ Body text (SF Pro, 16pt, Secondary)                                │
│                                                                                │
│                                                                                │ 24pt
│   ┌──────────────────────────────────────────────────────┐                    │
│   │                 Upgrade to Premium                   │                    │ 50pt
│   │              ↑ Primary CTA Button                    │                    │
│   └──────────────────────────────────────────────────────┘                    │
│                                                                                │
│                      Maybe Later                                              │ 20pt
│                  ↑ Secondary action                                            │
│                                                                                │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🌙 **Dark Mode Variations**

### Home Screen (Dark Mode)
```
┌────────────────────────────────────────────────────────────────────────────────┐ 
│  ┌─ Safe Area ─┐                                                               │
│  │ 9:41 AM    ◯ ◯ ◯                                                  100% ⚡   │ 47pt
│  └─────────────┘                                                               │
│  ↑ Status bar - White text on black background                                │
│                                                                                │
│  ┌─ 16pt margin ─┐                                              ┌─ 16pt ─┐    │
│  │                                                              │         │    │
│  │   Good evening! What's for dinner? 🌙                       │         │    │ 32pt
│  │   ↑ Dynamic greeting with moon emoji (white text)           │         │    │
│  │                                                              │         │    │
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │                                                      │  │         │    │
│  │   │           [Hero Food Image 16:9]                    │  │         │    │ 200pt
│  │   │              358x200pt                              │  │         │    │
│  │   │         Creamy Tuscan Chicken                       │  │         │    │
│  │   │                                                      │  │         │    │
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │   ↑ Card: .systemBackground (dark) with subtle elevation    │         │    │
│  │                                                              │         │    │
│  │   Creamy Tuscan Chicken                                      │         │    │ 28pt
│  │   ↑ .label (white text in dark mode)                        │         │    │
│  │                                                              │         │    │
│  │   ⏱️ 25 min    🔥 Easy    🇮🇹 Italian                        │         │    │ 24pt
│  │   ↑ .secondaryLabel (light gray text)                       │         │    │
│  │                                                              │         │    │
│  │   A rich, creamy chicken dish with sun-dried tomatoes       │         │    │ 40pt
│  │   and fresh spinach. Perfect for a cozy dinner at home.     │         │    │
│  │   ↑ .secondaryLabel (readable gray in dark mode)            │         │    │
│  │                                                              │         │    │
│  │   ┌──────────────────────────────────────────────────────┐  │         │    │
│  │   │               Get New Suggestion                     │  │         │    │ 50pt
│  │   │          ↑ Brand orange (#FF7A47 - dark variant)     │  │         │    │
│  │   └──────────────────────────────────────────────────────┘  │         │    │
│  │                                                              │         │    │
│  │   [See Recipe]  [Save]  [Order]                             │         │    │ 44pt
│  │   ↑ Orange text on dark background                          │         │    │
│  │                                                              │         │    │
│  └──────────────────────────────────────────────────────────────┘         │    │
│  ↑ Overall background: .systemBackground (pure black/dark gray)            │    │
│                                                                            │    │
│  ┌─ Tab Bar ─────────────────────────────────────────────────────────────┐ │    │
│  │                                                                        │ │    │ 83pt
│  │    🏠 Home         ❤️ Favorites         ⚙️ Settings                   │ │    │
│  │  ↑ Selected    ↑ Available (Premium)  ↑ Available                    │ │    │
│  │  Orange tint   Gray tint              Gray tint                       │ │    │
│  └────────────────────────────────────────────────────────────────────────┘ │    │
│  ↑ Tab bar: .systemBackground with .separator line                          │    │
└────────────────────────────────────────────────────────────────────────────────┘
```

### Color Adaptations for Dark Mode
- **Primary Orange**: `#FF6B35` → `#FF7A47` (slightly lighter)
- **Card Background**: `.systemBackground` (auto-adapts)
- **Text Colors**: `.label`, `.secondaryLabel` (auto-adapts)
- **Shadows**: Reduced opacity (0.1 → 0.05) for subtlety

---

## 📐 **Component Specifications**

### Button Specifications
```swift
// Primary Button
.frame(height: 50)
.frame(maxWidth: .infinity)
.background(Color("PrimaryOrange"))
.foregroundColor(.white)
.font(.body.weight(.medium))
.cornerRadius(12)

// Secondary Button (Outlined)
.frame(height: 44)
.frame(maxWidth: .infinity)
.background(Color.clear)
.foregroundColor(Color("PrimaryOrange"))
.font(.callout.weight(.medium))
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color("PrimaryOrange"), lineWidth: 1.5)
)

// Text Button
.foregroundColor(Color("PrimaryOrange"))
.font(.body.weight(.medium))
```

### Card Specifications
```swift
// Suggestion Card
.frame(width: 358, height: ~400)
.background(Color(.systemBackground))
.cornerRadius(16)
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
.padding(.horizontal, 16)

// Favorites Card
.frame(width: 171, height: 200)
.background(Color(.systemBackground))
.cornerRadius(12)
.shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 1)
```

### Typography Scale
```swift
// Navigation Titles
.font(.largeTitle.bold())          // 34pt

// Section Headers  
.font(.title.bold())               // 28pt

// Card Titles
.font(.title2.bold())              // 22pt

// Body Text
.font(.body)                       // 17pt

// Metadata/Captions
.font(.caption.weight(.medium))    // 12pt
```

### Spacing Constants
```swift
let screenMargin: CGFloat = 16      // Screen edges
let cardPadding: CGFloat = 16       // Internal card padding
let elementSpacing: CGFloat = 16    // Between major elements
let sectionSpacing: CGFloat = 24    // Between sections
let componentSpacing: CGFloat = 12  // Between related components
```

---

## 🎯 **Accessibility Specifications**

### VoiceOver Labels
```swift
// Suggestion Card
.accessibilityLabel("Meal suggestion: \(meal.title)")
.accessibilityValue("\(meal.prepTime) minutes, \(meal.difficulty) difficulty")
.accessibilityHint("Double tap to get recipe details")

// Action Buttons
Button("Get New Suggestion") { }
    .accessibilityLabel("Get new meal suggestion")
    .accessibilityHint("Generates a different meal recommendation")

Button("Save") { }
    .accessibilityLabel("Save to favorites")
    .accessibilityHint("Requires premium subscription")
```

### Dynamic Type Support
- **All text scales** with user's preferred size
- **Layout adapts** to larger text (stack vertically when needed)
- **Touch targets maintain** 44pt minimum even with large text
- **Content remains readable** at accessibility sizes (AX1-AX5)

### Color Contrast
- **Text on background**: 4.5:1 minimum ratio
- **Large text (18pt+)**: 3:1 minimum ratio  
- **Interactive elements**: Clear visual distinction
- **Focus indicators**: High contrast outlines

---

**Remember**: These wireframes represent the "invisible interface" philosophy - every pixel serves the user's primary goal of discovering what to eat. The layouts prioritize content over chrome, actions over options, and clarity over complexity. 📱✨
