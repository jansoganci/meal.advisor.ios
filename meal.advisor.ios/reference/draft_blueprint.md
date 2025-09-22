# **MealAdvisor Pivot: Draft Blueprint**

This document consolidates the strategic recommendations from the Gemini, OpenAI, and Perplexity analyses. It serves as the single source of truth for the product pivot, technical implementation, and launch strategy, aligning with the founder's philosophy of "simplicity is the ultimate sophistication" and a "ship fast, iterate faster" development approach.

## 1. Product Definition

*   **Core Value Proposition:** MealAdvisor is the simplest way to answer "What should I eat today?" using a smart, personalized AI.
*   **Target User Persona:** Busy professionals and individuals (age 25-44) experiencing "meal decision fatigue" who value convenience and health but are overwhelmed by complex nutrition trackers.
*   **Key Differentiators:**
    *   **Radical Simplicity:** A "one-button" user experience focused entirely on decision-making, not tedious tracking.
    *   **Speed to Value:** Delivers a useful meal suggestion in under 30 seconds from app open.
    *   **Intelligent Personalization:** Differentiates from generic recipe apps by using AI to learn user preferences and goals over time.
    *   **Global Reach:** Retains the existing 14-language support as a key advantage over less localized competitors.

## 2. App Structure & User Experience

The app will be reduced to a minimal, highly focused structure to eliminate confusion.

*   **Exact Number of Screens:** **Two** primary screens for the core user flow.
    1.  **Home Screen (The Decision Engine)**
    2.  **Settings Screen**

*   **Detailed Description of Each Screen:**
    *   **Onboarding:** This is not a screen, but an ephemeral, one-time prompt on the Home Screen. On first launch, the app asks a maximum of two questions: 1) "Any dietary needs?" (e.g., toggles for Vegan, Gluten-Free) and 2) "What's your main goal?" (e.g., toggles for Lose Weight, Maintain, Build Muscle). A "Skip for now" button is prominent.
    *   **Home Screen:** This is the entire app for most users.
        *   **Initial State:** A clean screen with the prompt "What should I eat today?" and a single, large "Get Suggestion" button.
        *   **Suggestion State:** After tapping the button, the screen replaces the prompt with a single `MealSuggestionCard`. This card displays a high-quality image of the meal, the meal name, and a one-sentence description (e.g., "500 kcal • High protein • Good for recovery").
        *   **Interaction:** Below the card are two clear buttons: **"👍 Love it"** and **"👎 Another idea"**. Tapping "👎" instantly loads a new suggestion. Tapping "👍" saves the meal to the user's history and reveals a small, non-intrusive link to "View Recipe & Details" (a premium feature).
    *   **Settings Screen:** Accessible via a small, discreet icon on the Home Screen. This screen is a simple list containing:
        *   Link to edit dietary preferences.
        *   Link to view saved "Loved" meals.
        *   A single, clear call-to-action: **"Upgrade to Premium"**.
        *   Language selection.

*   **User Flow (Time to First Value < 30 seconds):**
    1.  User opens app.
    2.  (First time only) Sees non-blocking prompt for diet/goals, makes a selection or skips.
    3.  Taps "Get Suggestion."
    4.  Receives the first meal suggestion.

*   **Navigation Structure:** **No tab bar.** The app is a single main screen. The only navigation is the icon to access the secondary Settings screen. This maximizes focus on the core action.

## 3. Feature Prioritization

This list is a synthesis of all three analyses, prioritizing speed of implementation.

*   **MVP Features (Must-Have for Launch):**
    1.  **AI Meal Suggestion Engine:** The core function.
    2.  **Minimalist Onboarding:** The two-question prompt on first launch.
    3.  **Simple Feedback Loop:** The "👍 Love it" / "👎 Another idea" buttons.
    4.  **Basic Personalization:** Ability to set and save dietary restrictions/goals.
    5.  **Multi-Language Support:** **Decision:** Keep this. Per the OpenAI analysis, this is a powerful existing asset and a key differentiator. Temporarily disabling it (Gemini's suggestion) saves minimal time but sacrifices a major strength.

*   **Phase 2 Features (Post-Launch):**
    *   **Photo-Based Input:** (From Perplexity) Introduce a small camera icon to allow users to snap a photo of their fridge/pantry for context-aware suggestions. This is a powerful, innovative feature that can be a major differentiator.
    *   **Simple Meal History:** A list of "Loved" meals, accessible from the Settings screen.
    *   **Proactive Notifications:** (From OpenAI) Smart, timed notifications (e.g., "Lunch idea: How about a quinoa salad?").

*   **Free vs. Premium Tier Breakdown:**
    *   **Free Tier (The Hook):**
        *   **5 free meal suggestions per day.** (Consensus from Gemini/Perplexity).
        *   Basic dietary preferences.
        *   Save up to 10 "Loved" meals.
    *   **Premium Tier (The Upgrade):**
        *   **Unlimited** meal suggestions.
        *   **"Plan My Week":** Repurpose the existing complex meal planner into a simple, on-demand premium feature. (OpenAI's recommendation).
        *   **Advanced Preference Tuning:** (e.g., "less spicy," "no cilantro").
        *   **Full Recipe Access & Details.**
        *   Save unlimited "Loved" meals.

*   **Features to Eliminate/Archive:**
    *   **IMMEDIATELY DISABLE:** Complex multi-screen meal planner, detailed analytics dashboards, shopping lists, social feeds, and the comprehensive onboarding wizard.

## 4. Technical Implementation Plan

*   **Technology Stack:**
    *   **Frontend:** **React Native/Expo.** (Unanimous) Stick with the current stack for speed and cross-platform capability.
    *   **Backend & Database:** **Supabase.** (Unanimous) The existing backend is functional and sufficient for this pivot.
*   **Implementation Method: Refactor with Feature Flags.**
    *   **Decision:** We will **refactor**, not rebuild. This is the recommendation from Gemini and OpenAI and aligns best with the 4-6 week timeline and "ship fast" philosophy. A rebuild (Perplexity's suggestion) is too slow and risky for a solo developer.
    *   **Action:** Create a `features.json` config file in the codebase. Wrap all non-MVP UI and logic (weekly planner, analytics, etc.) in feature flags. This allows them to be instantly disabled for the free version and re-enabled for the premium tier.
*   **Database Schema Requirements:**
    *   `users`: Provided by Supabase Auth.
    *   `profiles`: To store `user_id`, `dietary_restrictions`, `goals`, `language`.
    *   `recommendation_requests`: To log `user_id`, `timestamp`, `user_query`, `llm_response`, and `response_time_ms`.
    *   `feedback`: To log `request_id`, `user_id`, and `is_helpful` (boolean).
*   **AI/LLM Integration Strategy:**
    *   **Model:** Use **Groq with Llama 3 8B**. (Gemini's recommendation). This is the best choice for the primary goal of near-instant (<3 second) response time, which is a critical UX factor.
    *   **Implementation:** All LLM calls must be routed through a **Supabase Edge Function**. This keeps API keys secure and allows for centralized prompt management and caching. The function should be optimized to request a structured JSON response from the LLM.

## 5. Launch & Growth Strategy

*   **App Store Optimization (ASO):**
    *   This will be integrated from the initial keyword research document.
    *   **App Title:** `MealAdvisor: What Should I Eat?`
    *   **Subtitle:** `AI Meal Decision Helper`
    *   **Keywords:** `meal, decision, dinner, tonight, eat, food, ideas, suggestions, fatigue`
    *   **Screenshots:** Must showcase the new, radically simple UI. The first screenshot should be the Home Screen with a beautiful meal suggestion.
*   **Pricing and Monetization Model:**
    *   **Model:** Freemium Subscription.
    *   **Price:** **$4.99/month or $29.99/year.** This is the consensus "no-brainer" price point from Gemini/OpenAI. It's accessible enough for an impulse subscription but sustainable. The aggressive $2.99/mo price from Perplexity can be tested later if conversion rates are low.
*   **Success Metrics and KPIs:**
    *   **Primary North Star Metric:** **D7 Retention.** (Target: 20%+). This measures if the app is becoming a habit.
    *   **Secondary Guard Metric:** **Time to First "👍"**. (Target: < 30 seconds). This measures the core loop's efficiency.
    *   **Counter Metric:** **"👎" taps per session.** (Target: < 2). This measures suggestion quality.
*   **4-Week Development Timeline (Refactor approach):**
    *   **Week 1:** Setup feature flags and strip out all non-MVP UI. Create the new single-screen Home and Settings UI shells.
    *   **Week 2:** Implement the new Onboarding and Suggestion Card components. Optimize the Supabase Edge Function to call Groq and return a meal suggestion.
    *   **Week 3:** Wire up the feedback loop (👍/👎), user preferences, and premium feature gates.
    *   **Week 4:** Final testing, bug fixing, and preparing for App Store submission.

## 6. Risk Mitigation

*   **Primary Risk: Technical Debt from Refactor.**
    *   **Mitigation:** The feature flag approach contains the old code. Schedule a "Cleanup Sprint" for Month 2 to permanently remove the disabled code once the pivot is validated in the market.
*   **Risk: Poor AI Suggestion Quality.**
    *   **Mitigation:** The "👎 Another idea" button provides an immediate remedy for the user. The feedback data collected is critical and must be reviewed weekly to fine-tune the AI prompts in the Supabase function.
*   **Risk: Low Premium Conversion.**
    *   **Mitigation:** The free version is designed for high-volume engagement and word-of-mouth. Revenue is a secondary goal to validation. If conversion is low, the "Plan My Week" feature can be marketed more heavily, or the price can be A/B tested.