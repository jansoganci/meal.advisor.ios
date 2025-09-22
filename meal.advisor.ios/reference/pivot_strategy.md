Excellent. This SEO-first analysis provides a clear, data-driven roadmap. It aligns perfectly with the founder's philosophy of radical simplification and building what users are actively searching for.

Based on this document, here are the specific technical recommendations to execute the pivot within a 4-6 week timeline.

---

### 1. React Native App Architecture (for <10s AI Response)

To achieve the "instant value" goal, the architecture must be ruthlessly simple. The app should do one thing well: answer "What should I eat?".

*   **Single-Screen Focus:** Eliminate all existing navigation. The entire app is a single `HomeScreen` that presents the "One-Question Interface."
*   **Minimalist State Management:** Do not use Redux or MobX. Rely exclusively on React's built-in `useState` and `useContext` hooks. This is faster to implement and sufficient for managing the query, loading state, and the final recommendation.
*   **Optimized API Flow:**
    1.  User opens the app, the `HomeScreen` is immediately visible.
    2.  User types in the input box (or taps a pre-filled prompt like "What should I eat tonight?").
    3.  On submission, the app sets a loading state (`setLoading(true)`), displaying a simple `ActivityIndicator` or a skeleton loader.
    4.  A single API call is made to a Supabase Edge Function.
    5.  On response, the app updates its state (`setRecommendation(data)`, `setLoading(false)`) and displays the result in a clean, readable `MealSuggestionCard` component.
*   **Perceived Performance:** The key is managing the *perception* of speed. The UI must be responsive instantly, with a clear loading state, even if the LLM takes 5-7 seconds. The `<10s` goal is from app-open to value, and this architecture minimizes app-side delays.

### 2. LLM Model Selection & Implementation

The choice must balance cost, speed, and quality. For this use case, **speed is the most critical factor.**

*   **Recommended Model:** Use a fast inference provider like **Groq** running the **Llama 3 8B Instruct** model. It offers unparalleled speed (hundreds of tokens/sec), which is essential for the "instant" feel, at a very low cost. This is a decisive advantage over slower, more expensive models like GPT-4.
*   **Implementation:**
    1.  Create a **Supabase Edge Function** named `get-meal-recommendation`. This is critical for securely storing and using your LLM API key, rather than embedding it in the app.
    2.  The function will receive the user's query from the React Native app.
    3.  It will then make a `fetch` request to the Groq API with a carefully engineered prompt.
    4.  **Prompt Engineering:** The prompt should instruct the LLM to return a response in a structured **JSON format** to ensure reliability.

    **Example Prompt for the Edge Function:**
    ```
    You are MealAdvisor, a helpful AI assistant that gives a single, simple meal suggestion.
    Do not be chatty. Respond only with a JSON object.
    The user's request is: "${userQuery}".
    Based on the request, provide one meal idea.

    The JSON object must have the following structure:
    {
      "mealName": "Name of the dish",
      "description": "A brief, enticing one-sentence description.",
      "type": "Cooking or Ordering"
    }
    ```

### 3. Supabase Database Schema

The schema must be simple and directly support tracking the keyword strategy and user feedback loop.

Create two primary tables:

1.  **`recommendation_requests`**: To track every query and its outcome.
    *   `id` (uuid, pk)
    *   `user_id` (uuid, fk to `auth.users`)
    *   `created_at` (timestamp)
    *   `source_keyword` (text, nullable): *Crucial for SEO tracking. Populate this from the deep link parameter, e.g., "what-should-i-eat-tonight".*
    *   `user_query` (text): The actual text the user typed.
    *   `llm_response_payload` (jsonb): The full JSON response from the LLM.
    *   `response_time_ms` (integer): Calculated in the Edge Function to track the speed metric.

2.  **`feedback`**: To capture the simple "Did this help?" interaction.
    *   `id` (uuid, pk)
    *   `request_id` (uuid, fk to `recommendation_requests`)
    *   `user_id` (uuid, fk to `auth.users`)
    *   `created_at` (timestamp)
    *   `is_helpful` (boolean): `true` for thumbs up, `false` for thumbs down.

This schema is minimal, fast to build, and directly measures what matters for the pivot.

### 4. App Store Optimization (ASO) Technical Implementation

This involves both store configuration and in-app code.

*   **App Store / Google Play Metadata:**
    *   **Action:** Manually update the app's listing in App Store Connect and the Google Play Console with the exact Title, Subtitle, and Keyword list from the research document. This is a configuration task, not a code task.
*   **Deep Linking (Universal Links & App Links):** This is the highest priority technical ASO task.
    1.  **Website:** Create and host two files on your `mealadvisor.com` web server:
        *   `/.well-known/apple-app-site-association` (for iOS)
        *   `/.well-known/assetlinks.json` (for Android)
        These files authorize your domain to open your app.
    2.  **React Native Code:** Configure the `linking` object for React Navigation to handle incoming URLs and extract the `source_keyword`.

        ```javascript
        const linking = {
          prefixes: ['https://mealadvisor.com', 'mealadvisor://'],
          config: {
            screens: {
              Home: {
                path: 'recommend/:source_keyword?', // e.g., /recommend/what-should-i-eat
              },
            },
          },
        };
        ```
    3.  **Native Project Config:**
        *   **iOS (Xcode):** In `Signing & Capabilities`, add your domain (`applinks:mealadvisor.com`) to the `Associated Domains` section.
        *   **Android (`AndroidManifest.xml`):** Add an `<intent-filter>` to your main activity to capture the URLs.

*   **App Indexing:** By correctly implementing Universal Links/App Links and having a web presence (blog, landing page) that links to them, app content becomes discoverable in Google Search results automatically.

### 5. Analytics Setup

Track the metrics that validate the pivot's success. Use a product analytics tool like **PostHog** or Mixpanel for its simplicity and focus on user funnels.

**Key Events to Track:**

*   `app_opened`: Fired on app launch.
*   `recommendation_requested`:
    *   **Properties:** `source_keyword` (from deep link), `user_query`
*   `recommendation_received`:
    *   **Properties:** `response_time_ms`, `mealName`
*   `feedback_submitted`:
    *   **Properties:** `is_helpful` (true/false)

**Mapping Events to Success Metrics:**

*   **`<10s time-to-value`**: Measure the average `response_time_ms` from the `recommendation_received` event.
*   **`95% session completion rate`**: Create a funnel in your analytics tool: `app_opened` -> `recommendation_requested` -> `recommendation_received`. A high completion rate for this funnel indicates immediate value delivery.
*   **`85% positive feedback rate`**: Analyze the `is_helpful` property on the `feedback_submitted` event.
*   **Organic Downloads & Keyword Rankings:** These are tracked directly in App Store Connect and Google Play Console, not via in-app analytics.

These technical decisions directly support the SEO-first strategy, align with the founder's philosophy of speed and simplicity, and are achievable by a solo developer in the 4-6 week timeframe.

I am awaiting the remaining two analysis documents to refine these recommendations further.
