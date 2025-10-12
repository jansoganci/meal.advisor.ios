# MealAdvisor Pivot Blueprint (iPhone-Only, Simplicity‑Driven)

This is the definitive implementation guide for the 4–6 week pivot to a radically simplified "What should I eat today?" utility. It reconciles your draft with insights from Gemini, Perplexity, and OpenAI analyses, applies iOS Human Interface Guidelines, and prioritizes shipping fast with focus.

## 1) Strategic Alignment & Corrections

- Core principle: One-tap decision relief. Deliver a great meal suggestion instantly; everything else is secondary.
- **Platform**: iPhone only. Native iOS app with SwiftUI. No Android, no cross-platform. Focus 100% on iOS quality and Apple ecosystem integration.
- Rebuild vs refactor: Research favors a focused rebuild of the front-end shell to avoid legacy complexity (Gemini, Perplexity). Recommended: create a new native iOS app with SwiftUI that reuses Supabase and existing auth; keep v1.0.9 code archived. If time-constrained, run the new flow behind a feature flag while leaving old routes unreachable.
- Recipe access: Keep "See Recipe" free (Gemini). Gating recipes harms adoption. Make Favorites and Unlimited Swaps the first premium levers.
- Weekly planning: Do not repurpose the old planner. If needed later, add a simple read‑only "Weekly View" after retention wins (Gemini) — not a full planner.
- **Photo input**: NOT IMPLEMENTED. "What's in my fridge?" feature is explicitly excluded from roadmap. Adds complexity, latency, and cognitive load with questionable value.
- Multi‑language: Keep existing translations if already stable; freeze expansion for V1. Don't let localization delay the pivot. Prioritize English polish + iOS HIG.

## 2) Product Definition (iOS‑First)

- Value proposition: "The simplest way to decide what to eat — right now."
- Target user: Busy iPhone users (25–44) with meal decision fatigue; want quick, healthy-ish ideas without tracking.
- Differentiators: Single‑tap flow, instant suggestion, tasteful iOS feel (HIG), personalizes gently from minimal input.

## 3) V1 Scope (Ship in 4–6 Weeks)

### Must‑Have
- Home (Decision Engine):
  - Primary button: "What should I eat for [Breakfast/Lunch/Dinner]?" (auto time-of-day).
  - Suggestion card: hero image, title, prep time, 2–3 badges (e.g., High protein; Under 500 cal; 20 min).
  - Actions: "See Recipe" (free), "Show Another" (swap; 3–5/day free), "Save" (Favorites — premium).
  - Optional: "Find delivery" deep link to Uber Eats/DoorDash search for cuisine/dish.
- Authentication: Optional, just‑in‑time sign‑in prompt.
  - Flow: User taps "What should I eat?" → begin fetching suggestion → present a non‑blocking bottom sheet: "Save your preferences for better suggestions?" with primary "Sign in with Apple" (and Google/Email) and secondary "Maybe later".
  - Both choices proceed to show the suggestion. Do not add artificial delay; start fetch before showing the sheet.
  - Sign‑in is required later for Premium and Favorites; suggested again at those moments.
- First‑run micro‑onboarding (inline sheet on Home): Allergies/dislikes; one goal (Healthy / Weight loss / Muscle); time available.
- Settings (lightweight): Edit preferences, Manage subscription, Legal links, Language selector (if kept), Sign in/out (Sign in with Apple preferred).
- Premium gates: Unlimited swaps + Favorites.

### Nice‑to‑Have (V1.1-Phase 2)
- Advanced filters (cuisine/diet) as premium.
- Simple Weekly View (read‑only list of 7 suggestions; no planning UX).
- **Smart notifications at mealtimes** (opt‑in; quiet, contextual) — PHASE 2 ONLY, not MVP.
- Food delivery integration (simple deep links to UberEats/DoorDash).

### Explicitly Out (Archive)
- Calorie/macro tracking, charts, full planners, social/community, shopping lists, complex onboarding, analytics dashboards.
- **Photo input / "What's in my fridge?" feature** — Permanently excluded. Adds complexity without clear user value.
- **Android or cross-platform development** — iPhone only. Native iOS SwiftUI focus.

## 4) Screen‑by‑Screen (HIG‑Aligned)

### Home (Primary)
- Layout: Edge‑to‑edge hero image; large title below; badges in a compact horizontal capsule row; prep time prominent.
- Controls: One large primary button (or floating FAB equivalent) when idle; when showing a result, use two prominent buttons: "Show Another" (primary) and "See Recipe" (secondary). "Save" as a heart icon on the card (gated if not premium).
- Motion/Haptics: Light haptic on suggestion fetch and save using `UIImpactFeedbackGenerator`; skeleton loading shimmer with SwiftUI animations; P95 suggestion < 3s.
- Accessibility: 44pt hit targets; Dynamic Type; VoiceOver labels for badges; sufficient contrast; Reduce Motion respected.

### Recipe (Modal or Push)
- Simple recipe card: ingredients, steps, servings, nutrition summary (short; no tracking). Keep images optimized for iPhone.
- Actions: "Start Cooking" (step view) and "Share" (system sheet). No account required to view.

### Settings (List)
- Items: Preferences, Favorites (premium), Manage Subscription, Language (if enabled), Privacy/Terms, Sign in/Out (Apple/Google/Email).
- Keep it terse; avoid nesting.

## 5) Technical Architecture

- App: Native iOS with SwiftUI + Xcode. iOS look/feel: use native iOS design patterns and HIG compliance; haptics via `UIImpactFeedbackGenerator`; gestures via native SwiftUI gesture recognizers.
- Auth: Supabase Auth with optional, just‑in‑time sign‑in.
  - Identity options: Sign in with Apple (required if any third‑party sign‑in is offered), Google OAuth, and Email.
  - Until sign‑in: maintain a device install ID to enforce free swap limits and basic personalization; migrate local state to the account on sign‑in.
- Data: Supabase Postgres.
- Edge Functions: `suggest` endpoint to compute a suggestion from curated recipes + user prefs; handle rate limits; return structured JSON.
- Content: Curated `recipes` table with metadata: title, image_url, cuisine, diet tags, allergens, calories, protein, ready_in_minutes, difficulty, popularity, seasonality; ensure image licensing and CDN hosting.
- Suggestion strategy: Filter by allergens/dislikes/time/goal → rank by popularity/fit → occasionally explore (epsilon-greedy) → cache per user/device + meal period for 2–4h to maximize speed and control costs.
- Suggestion strategy enhancements:
  - Pre‑cache: Maintain one ready suggestion per meal period (breakfast/lunch/dinner) so Home loads instantly; refresh cache on open or time‑bucket change.
  - Repeat prevention: Avoid suggesting any recipe from the user’s last 10–14 suggestions; respect explicit dislikes; enforce cuisine/ingredient variety where possible.
  - Exploration: Small exploration rate (e.g., 10–15%) to discover new favorites without sacrificing relevance.
- AI usage: Keep small LLM involvement (optional) for badge phrasing/short description; selection primarily deterministic over catalog for latency/cost control. If using LLM, run via Supabase Edge with strict JSON schema + timeouts; implement fallback to deterministic ranking.
- Caching: User‑context cache table + Core Data local cache + in‑memory/edge cache. Return cached suggestion instantly when valid; allow manual swap to fetch a new one.
- Feature flags/remote config: Simple KV in Supabase for price tests, free swap limits, notification timing.
- **Delivery deep links (Phase 2)**: Simple approach - use universal HTTPS links to open delivery apps/websites. Format: `https://www.ubereats.com/search?q={mealTitle}` or `https://www.doordash.com/search/?query={cuisine}`. iOS will prompt user to open in app if installed. No complex SDK integration needed. Add optional "Order Delivery" button on recipe detail screen that opens Safari/app with pre-filled search.

### Minimal Schema (add/confirm)
- `profiles(user_id, allergies text[], dislikes text[], goal text, time_bucket text, language text)`
- `recipes(id, title, image_url, cuisine text[], diet text[], allergens text[], calories int, protein int, ready_in_minutes int, badges text[], popularity float, season text[], source_url)`
- `favorites(user_id, recipe_id, created_at)`
- `suggestions(id, user_id nullable, device_id nullable, meal_period text, recipe_id, created_at, latency_ms, was_cached boolean)`
- `usage_counters(user_id nullable, device_id nullable, date, swaps_used int)`
- `events(user_id, name text, props jsonb, created_at)`

## 6) iOS‑Specific Implementation Notes

- HIG: Obvious primary action; minimum chrome; content-first design; delightful but restrained animation.
- StoreKit 2 (via native iOS APIs): Non‑consumable subscription with intro offer (e.g., 3‑day trial). Server verify receipts; entitlements cached client‑side using Core Data.
- Sign in with Apple (JIT): Present a benefit‑framed, optional bottom sheet during first suggestion fetch or on high‑intent actions (Save, swap limit). Include Google/Email. Ensure "Maybe later" is visible and not misleading. Return to the suggestion regardless of choice.
  - JIT prompt copy: Title “Save your preferences for better suggestions?” Primary “Sign in with Apple” (or Google/Email). Secondary “Maybe later”. Avoid coercive phrasing (e.g., “Create account to continue”).
- **Notifications (Phase 2)**: Ask consent contextually after value; schedule gentle meal‑time suggestions; respect Focus modes. NOT in MVP - defer to Phase 2 based on user feedback.
- Widgets (WidgetKit): Home Screen widget shows last cached suggestion with "Get Another" CTA; deep links into app; background refresh keeps content current. Implement via native WidgetKit extension; ship V1.1 if timeline tight.
- Siri Shortcuts & App Intents: Provide an intent like "Suggest a dinner" surfaced in Spotlight/Siri; donate after first use; include parameters (meal period) and support voice.
- Shortcuts personal automations: Encourage users (educational tip) to set a personal automation at habitual times (e.g., 6pm) to trigger the intent.
- Universal Links & Deep Linking: Support routes that mirror top intent queries (e.g., `/recommendation/quick-dinner`, `/cuisine/italian-tonight`, `/ingredients/chicken`, `/problem/nothing-sounds-good`). No need for `LSApplicationQueriesSchemes` - use universal HTTPS links for delivery apps.
- App Review readiness: No health claims; nutrition info is “informational”; privacy policy clear; link‑outs labeled; subscriptions transparent; restore purchases prominent.
- Performance budgets: P95 suggestion < 3s, cold start < 2s on recent iPhones, image payload < 500KB hero, crash‑free > 99%.
- Accessibility: Dynamic Type, VoiceOver, Reduce Motion/Transparency, sufficient contrast. Use native iOS accessibility APIs for optimal screen reader support.

## 7) Monetization & Pricing

- Free: 3–5 swaps/day, recipe viewing, basic prefs.
- Premium: Unlimited swaps, Favorites, (later) advanced filters and Weekly View.
- Pricing tests (remote‑config A/B):
  - Ladder A: $4.99/mo, $29.99/yr.
  - Ladder B: $2.99/mo, $19.99/yr.
- Paywall: Native modal after reaching swap limit or tapping Save without subscription; clear value bullets; screenshots; intro offer.

## 8) Analytics & Metrics (from OpenAI metrics depth)

- Core KPIs: Time‑to‑First‑Value (TTFV) < 45s on first run; DAU/MAU > 20%; D7 ≥ 35% target; D30 ≥ 25% stretch; conversion 3–7% early; P95 suggestion latency < 3s; crash‑free > 99%.
- Cost guardrail: Cost/suggestion within unit economics (premium ARPU coverage).
- Event map (examples):
  - `app_open`, `sign_in_prompt_shown` {trigger: first_suggestion|save|swap_limit}, `sign_in_started`, `sign_in_succeeded`, `sign_in_dismissed`, `onboarding_completed`, `suggest_request` {meal_period, cached}, `suggest_shown` {latency_ms}, `swap_used`, `recipe_viewed`, `favorite_tapped` {subscribed}, `paywall_shown` {variant}, `subscription_started` {plan, price_variant}, `notification_opened`, `notifications_paused` {duration}.
  - `notification_scheduled` {type: mealtime|digest|churn}, `widget_tap`, `siri_intent_invoked`, `repeat_avoided` {window_days}, `collection_viewed` {name}.
- Tooling: Supabase events table + lightweight client queue; native iOS crash reporting via Xcode Organizer; Firebase Crashlytics or Sentry for stability.

## 9) 4–6 Week Execution Plan

Week 1 — Design & Scaffold
- Lock V1 scope; finalize two-screen flows; build SwiftUI app shell with Home/Settings; add skeleton loaders, haptics, dark mode.
- Set up Supabase tables; stub Edge `suggest` with deterministic ranking; import 150–300 curated recipes with images/metadata.

Week 2 — Core Loop & Perf
- Implement onboarding micro‑prompts; wire suggest button → Edge; implement caching and free swap counter; add remote config.
- Instrument analytics; measure P95 latency; optimize images via CDN; add delivery deep links.

Week 3 — Premium & Entitlements
- Add Favorites (gated); integrate native StoreKit 2 subscription; receipt validation; remote price variants.
- Paywall flows; restore purchases; Sign in with Apple using native iOS APIs.

Week 4 — Polish & TestFlight
- Accessibility pass, crash/stability hardening; empty/error states; offline last‑suggested fallback.
- TestFlight with 10–20 users; collect feedback on quality and speed; tune ranking and badges.

Weeks 5–6 — Iterate & Ship
- Address feedback; tighten copy; refine images and recipe coverage; ASO assets; App Review prep.
- Optional: enable a simple Weekly View or advanced filters if ahead of schedule; otherwise ship and learn. If capacity allows, ship the native WidgetKit extension in V1.1.

## 10) Risks & Mitigations

- Suggestion quality: Start with curated set; weekly review hit‑rate; add exploration/exploitation; incorporate explicit dislikes.
- Latency: Cache aggressively; keep AI minimal; prewarm suggestions by meal period.
- App Review: Avoid health claims; clear pricing; functional free tier with recipe viewing; restore purchases visible.
- Content/IP: Use licensed images or own assets; store source_url; honor licenses; compress images.
- Conversion: Make Save the first premium lock; test price ladders; add tasteful after‑value paywall prompts.

## 11) ASO & Launch

- Name (≤30): "MealAdvisor: What to Eat"
- Subtitle (≤30): "Instant AI meal ideas"
- Keywords (en‑US, ≤100, no spaces/repeats): `tonight,quick,dinner,lunch,healthy,highprotein,weightloss,recipe,suggestions,cook,food,fast`
- Keywords (es‑MX, US indexing boost): `que,comer,hoy,cena,rapida,ideas,recetas,facil,pollo,saludable`
- Screenshots: 1) Single‑tap to get a meal; 2) Clean recipe card; 3) Favorites (Premium). Keep iPhone‑first visuals.
- Categories: Food & Drink (primary), Health & Fitness (secondary).
- In‑app review prompt: Only after ≥3 positive sessions; never on first run.
- Locales: Enable `es‑MX` locale in App Store Connect (US storefront) to expand indexing via the Spanish (Mexico) keyword field while keeping UI English.
- Apple Search Ads (starter plan):
  - Campaigns: Brand (exact), Decision Core (exact), Decision Broad, Competitor Discovery (broad only).
  - Exact seeds: "what should i eat", "what to eat", "what to eat tonight", "dinner ideas", "quick dinner", "meal ideas", "what to cook".
  - Negatives: tracker, calorie, macro, barcode, myfitnesspal.
  - Creative sets: Pair decision screenshot with dinner/healthy variants.
  - Dayparting: Bias spend to 11:00–13:00 and 17:00–19:00 local time to align with meal decision windows.

---

## 12) Retention & Lifecycle

- Mealtime notifications (opt‑in):
  - Windows: Lunch 11:45–12:30; Dinner 17:30–18:30 (local time); no breakfast in V1.
  - Suppression: Don’t send if app opened or suggestion shown in past 2h; cap 1/day by default; pause for 48h after two ignores.
  - Deep link: Open directly to current meal period’s cached suggestion.
- Quiet hours & fatigue: Provide a toggle to "Pause notifications until tomorrow" and a weekly pause option; respect system Focus modes.
- Weekly digest (optional opt‑in): Sunday afternoon with “Your 3 quick dinners this week” linking to a lightweight Weekly View (read‑only), or to three suggestions.
- Churn rescue: If 5+ days idle, send one quiet push: “No‑cook dinner in 5 mins?” linking to 10‑minute recipes.
- Content cadence: Add 20–30 curated recipes/month; maintain seasonal collections (e.g., Summer Salads, Cozy Soups) and a small "Trending" tag based on aggregate popularity; ensure top‑tier images.
- Personalization rules: Respect dislikes; avoid repeats from last 10–14 suggestions; rotate cuisines; bias to user’s liked badges.
- Widgets & Siri:
  - Widget shows last cached suggestion + “Get Another”; background refresh to keep timely.
  - Siri/App Intent “Suggest a dinner” with optional meal period; donate intent after first use to surface in Spotlight.

### Ingredient Hint (P2 experiment)
- Goal: Offer an optional, low‑friction hint like a chip — “Use chicken tonight?” — derived from recent favorites/suggestions.
- Behavior: Appears as a small, dismissible chip above the Suggest button; tapping filters the next suggestion by that ingredient; disappears after use; never blocks the one‑tap flow.

### Post‑Launch Experiments (Prioritized)
- P0
  - Notification timing: weekday vs weekend windows; 1/day vs 2/day.
  - Widget/Siri adoption impact on DAU and TTFV.
  - Repeat‑prevention window A/B: 7 vs 10 vs 14 days.
- P1
  - Paywall triggers: after swap limit vs Save tap vs both (which converts best, least intrusive).
  - Seasonal collection badge vs neutral badge on engagement.
- P2
  - Photo input (“fridge scan”) impact on latency and engagement.
  - Referral unlock: 7‑day Premium for both inviter/invitee.

---

## 10) Key Implementation Decisions

*Finalized decisions made during pre-development planning (September 2025)*

### App Identity & Branding
- **App Name**: "MealAdvisor: What to Eat"
- **Bundle Identifier**: Already configured in Xcode project
- **App Store Categories**: Primary: Food & Drink, Secondary: Health & Fitness
- **App Icon**: Already designed and ready

### Content & Data Strategy
- **Recipe Images**: Curated Unsplash API photos (bright, clean, appetizing style)
- **Initial Database**: 150-300 recipes across 5 cuisines + 10 diet types
- **Cuisines Focus**: Italian, American, Asian, Mediterranean, Mexican
- **Diet Types**: Vegetarian, Vegan, Gluten-Free, Dairy-Free, Low-Carb/Keto, High-Protein, Mediterranean, Paleo, Low-Sodium, Quick & Easy

### Supabase Schema (Simple Names)
```sql
meals              -- Core meal data (id, title, description, prep_time, difficulty, cuisine, diet_tags, image_url, ingredients, instructions)
users              -- User profiles
user_preferences   -- Diet restrictions, cooking time available
favorites          -- Saved meals (premium feature)
meal_ratings       -- User feedback on suggestions
```

### Monetization Strategy
- **Monthly Premium**: $2.99 with 3-day free trial
- **Annual Premium**: $24.99 (30% discount) with NO free trial
- **Strategy**: Trial on monthly converts to yearly naturally
- **Premium Features**: Unlimited favorites, advanced filters, meal planning (Phase 2)

### Technical Approach
- **Analytics**: Supabase built-in + minimal privacy-first tracking
- **Push Notifications**: Minimal - meal reminders only (2-3 per day max)
- **Image Strategy**: Unsplash API for MVP, upgrade to premium stock later
- **Performance Targets**: <3s suggestion loading, <2s app launch

### User Experience Priorities
- **Primary Flow**: One-tap suggestion → instant result → clear actions
- **Navigation**: Tab bar (Home, Favorites, Settings)
- **Premium Integration**: Gentle nudging, never blocking core functionality
- **Error Handling**: Always provide recovery actions, cached fallbacks

---

This blueprint embodies "simplicity is the ultimate sophistication": one clear job, delightful execution, iOS‑native feel, and a build that can ship in weeks. After launch, improve the catalog, refine ranking, and explore premium depth — without compromising the single‑tap core.
