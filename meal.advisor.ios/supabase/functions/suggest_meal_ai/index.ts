/**
 * AI-First Meal Suggestion Edge Function
 * 
 * ARCHITECTURE FLOW:
 * 1. Check in-memory cache first (24h TTL) → Return if hit
 * 2. Try AI generation with 8s timeout → Return + cache if successful
 * 3. If AI times out → Return database fallback + continue AI in background
 * 4. Cache successful AI results for future requests
 * 
 * PERFORMANCE OPTIMIZATIONS:
 * - Cache-first approach reduces AI costs and response times
 * - Timeout prevents slow AI from blocking user experience
 * - Background AI generation ensures cache population
 * - Automatic cache cleanup prevents memory leaks
 * 
 * RESPONSE FIELDS:
 * - cachedResult: true if meal came from cache
 * - backgroundGenerated: true if AI was slow and DB fallback used
 * - aiGenerated: true if meal was AI-generated (cached or fresh)
 * - fallbackUsed: true if database fallback was used
 */

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type RequestPayload = {
  userId?: string;
  locale?: string;
  timeOfDay?: "breakfast" | "lunch" | "dinner";
  preferences: {
    dietaryRestrictions: string[]; // Meal.DietType raw values
    cuisinePreferences: string[];  // Meal.Cuisine raw values
    maxCookingTime: number;        // minutes
    difficultyPreference?: string; // Meal.Difficulty raw value
    excludedIngredients?: string[];
    servingSize: number;           // number of people
  };
  recentMealIds?: string[]; // last 10 shown (UUID strings)
  ingredientHint?: string | null;
};

type AIGeneratedMeal = {
  id: string;
  title: string;
  description: string;
  prepTime: number;
  difficulty: string;
  cuisine: string;
  dietTags: string[];
  ingredients: Array<{
    name: string;
    amount: string;
    unit: string;
  }>;
  instructions: string[];
  nutritionInfo: {
    calories: number;
    protein: number;
    carbs: number;
    fat: number;
  };
  imageURL?: string | null;
};

type AIResponse = {
  status: "ok" | "error";
  meal?: AIGeneratedMeal;
  error?: string;
  fallbackUsed?: boolean;
};

type CacheEntry = {
  meal: any;
  badges: string[];
  timestamp: number;
  ttl: number;
};

type ResponseBody = {
  meal?: any; // full row mapped to app shape
  badges?: string[];
  alternatives?: string[];
  reason?: string;
  status: "ok" | "no_match";
  aiGenerated?: boolean;
  fallbackUsed?: boolean;
  cachedResult?: boolean;
  backgroundGenerated?: boolean;
};

// Environment variables with safety checks
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");

// Validate required environment variables
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("❌ [Config] Missing required Supabase environment variables");
  throw new Error("Missing required Supabase configuration");
}

if (!GEMINI_API_KEY) {
  console.warn("⚠️ [Config] GEMINI_API_KEY not configured - AI generation will fail, fallback to database");
}

// In-memory cache with TTL
const cache = new Map<string, CacheEntry>();
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
const AI_TIMEOUT = 8000; // 8 seconds

// Cache utility functions
function generateCacheKey(preferences: RequestPayload['preferences'], timeOfDay?: string): string {
  const keyData = {
    dietaryRestrictions: preferences.dietaryRestrictions.sort(),
    cuisinePreferences: preferences.cuisinePreferences.sort(),
    maxCookingTime: preferences.maxCookingTime,
    difficultyPreference: preferences.difficultyPreference,
    excludedIngredients: (preferences.excludedIngredients || []).sort(),
    servingSize: preferences.servingSize,
    timeOfDay
  };
  return btoa(JSON.stringify(keyData));
}

function getFromCache(key: string): CacheEntry | null {
  const entry = cache.get(key);
  if (!entry) {
    return null; // Cache miss
  }
  
  const now = Date.now();
  if (now - entry.timestamp > entry.ttl) {
    cache.delete(key); // Remove expired entry
    return null;
  }
  
  return entry; // Cache hit
}

function saveToCache(key: string, meal: any, badges: string[]): void {
  const entry: CacheEntry = {
    meal,
    badges,
    timestamp: Date.now(),
    ttl: CACHE_TTL
  };
  cache.set(key, entry);
}

function cleanupExpiredCache(): void {
  const now = Date.now();
  for (const [key, entry] of cache.entries()) {
    if (now - entry.timestamp > entry.ttl) {
      cache.delete(key);
    }
  }
}

// AI-First meal generation using Gemini
async function generateMealWithAI(payload: RequestPayload): Promise<AIResponse> {
  console.log("🤖 [AI-First] Starting AI meal generation");
  
  if (!GEMINI_API_KEY) {
    console.log("🤖 [AI-First] No Gemini API key, will use fallback");
    return { status: "error", error: "No AI API key configured" };
  }

  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`;

  const systemPrompt = "You are a professional chef and nutritionist creating personalized meal suggestions. Generate a complete meal recipe based on user preferences.\n\n" +
    "CRITICAL REQUIREMENTS:\n" +
    "- Output MUST be valid JSON in the exact format specified below\n" +
    "- All measurements should be practical for home cooking\n" +
    "- Prep time must be realistic and accurate\n" +
    "- Include complete ingredients with amounts and units\n" +
    "- Provide step-by-step cooking instructions\n" +
    "- Calculate realistic nutrition information\n" +
    "- Ensure the meal matches ALL dietary restrictions and preferences\n" +
    "- Make it appetizing and well-described\n\n" +
    "DIETARY RESTRICTIONS TO RESPECT:\n" +
    payload.preferences.dietaryRestrictions.map(r => "- " + r).join('\n') + "\n\n" +
    "CUISINE PREFERENCES:\n" +
    payload.preferences.cuisinePreferences.map(c => "- " + c).join('\n') + "\n\n" +
    "MAX COOKING TIME: " + payload.preferences.maxCookingTime + " minutes\n" +
    "SERVING SIZE: " + payload.preferences.servingSize + " people\n" +
    "DIFFICULTY PREFERENCE: " + (payload.preferences.difficultyPreference || 'Any') + "\n" +
    "EXCLUDED INGREDIENTS: " + (payload.preferences.excludedIngredients?.join(', ') || 'None') + "\n" +
    "TIME OF DAY: " + (payload.timeOfDay || 'Any') + "\n\n" +
    "CRITICAL: Return ONLY raw JSON. Do NOT wrap in markdown, do NOT use ```json fences, do NOT add any text before or after the JSON.\n\n" +
    "OUTPUT FORMAT - raw JSON only:\n" +
    "{\n" +
    "  \"id\": \"generate-a-unique-uuid-string\",\n" +
    "  \"title\": \"Appetizing Meal Name\",\n" +
    "  \"description\": \"Mouth-watering description of the meal\",\n" +
    "  \"prepTime\": number_in_minutes,\n" +
    "  \"difficulty\": \"Easy\" | \"Medium\" | \"Hard\",\n" +
    "  \"cuisine\": \"Italian\" | \"Asian\" | \"Mediterranean\" | \"American\" | etc,\n" +
    "  \"dietTags\": [\"tag1\", \"tag2\"],\n" +
    "  \"ingredients\": [\n" +
    "    {\"name\": \"Chicken breast\", \"amount\": \"1\", \"unit\": \"lb\"},\n" +
    "    {\"name\": \"Olive oil\", \"amount\": \"3\", \"unit\": \"tbsp\"},\n" +
    "    {\"name\": \"Garlic cloves\", \"amount\": \"4\", \"unit\": \"cloves\"},\n" +
    "    {\"name\": \"Cherry tomatoes\", \"amount\": \"2\", \"unit\": \"cups\"},\n" +
    "    {\"name\": \"Fresh basil\", \"amount\": \"1/2\", \"unit\": \"cup\"},\n" +
    "    {\"name\": \"Parmesan cheese\", \"amount\": \"1/4\", \"unit\": \"cup\"},\n" +
    "    {\"name\": \"Pasta\", \"amount\": \"12\", \"unit\": \"oz\"},\n" +
    "    {\"name\": \"Salt\", \"amount\": \"1\", \"unit\": \"tsp\"},\n" +
    "    {\"name\": \"Black pepper\", \"amount\": \"1/2\", \"unit\": \"tsp\"}\n" +
    "  ],\n" +
    "  \"instructions\": [\n" +
    "    \"Pat chicken dry with paper towels, season both sides with salt and pepper\",\n" +
    "    \"Heat large skillet over medium-high, add 2 tbsp olive oil until shimmering\",\n" +
    "    \"Sear chicken 5-6 minutes per side until golden brown and cooked through (165°F)\",\n" +
    "    \"Remove chicken to plate, add remaining oil and minced garlic to pan\",\n" +
    "    \"Cook garlic 30 seconds until fragrant, add halved tomatoes, cook 3-4 minutes until bursting\",\n" +
    "    \"Meanwhile, boil pasta according to package directions, drain and reserve 1 cup pasta water\",\n" +
    "    \"Slice chicken, return to pan with cooked pasta, torn basil, and grated Parmesan\",\n" +
    "    \"Toss everything together, adding reserved pasta water as needed for sauce consistency\"\n" +
    "  ],\n" +
    "  \"nutritionInfo\": {\n" +
    "    \"calories\": number,\n" +
    "    \"protein\": number_in_grams,\n" +
    "    \"carbs\": number_in_grams,\n" +
    "    \"fat\": number_in_grams\n" +
    "  }\n" +
    "}";

  const userPrompt = `Create a delicious meal that perfectly matches these preferences. Make it unique, appetizing, and practical to cook at home. Consider the time of day (${payload.timeOfDay}) and ensure it's satisfying and nutritious.`;

  const body = {
    contents: [
      { role: "user", parts: [{ text: systemPrompt }] },
      { role: "user", parts: [{ text: userPrompt }] },
    ],
    generationConfig: {
      temperature: 0.7,
      top_p: 0.9,
      maxOutputTokens: 4096,
    },
  };

  try {
    console.log("🤖 [AI-First] Calling Gemini API for meal generation");
    const startTime = Date.now();
    
    const res = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    const duration = Date.now() - startTime;
    console.log(`🤖 [AI-First] Gemini API call took ${duration}ms`);

    if (!res.ok) {
      const errorText = await res.text();
      console.error("🤖 [AI-First] Gemini API error:", res.status, errorText);
      return { 
        status: "error", 
        error: `AI API error: ${res.status} - ${errorText}` 
      };
    }

    const data = await res.json();
    console.log("🤖 [AI-First] Received response from Gemini");

    const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    console.log("🤖 [AI-First] Extracted text from response");

    if (!text.trim()) {
      return { status: "error", error: "Empty response from AI" };
    }

    // Sanitize JSON response (remove markdown fences if present)
    let sanitizedText = text.trim();
    if (sanitizedText.startsWith('```json') && sanitizedText.endsWith('```')) {
      sanitizedText = sanitizedText.slice(7, -3).trim();
    } else if (sanitizedText.startsWith('```') && sanitizedText.endsWith('```')) {
      sanitizedText = sanitizedText.slice(3, -3).trim();
    }

    // Parse JSON response
    let aiMeal: AIGeneratedMeal;
    try {
      aiMeal = JSON.parse(sanitizedText);
      console.log("🤖 [AI-First] Successfully parsed AI response");
    } catch (parseError) {
      console.error("🤖 [AI-First] JSON parse error:", parseError);
      console.log("🤖 [AI-First] Raw response text:", text);
      return { status: "error", error: "Invalid JSON from AI" };
    }

    // Validate AI response structure
    const validation = validateAIMeal(aiMeal, payload.preferences);
    if (!validation.valid) {
      console.error("🤖 [AI-First] AI meal validation failed:", validation.errors);
      return { status: "error", error: `Invalid meal structure: ${validation.errors.join(', ')}` };
    }

    console.log("🤖 [AI-First] AI meal generation successful:", aiMeal.title);
    return { status: "ok", meal: aiMeal };

  } catch (error) {
    console.error("🤖 [AI-First] AI generation error:", error);
    return { 
      status: "error", 
      error: `AI generation failed: ${error.message}` 
    };
  }
}

// Validate AI-generated meal structure and preferences
function validateAIMeal(meal: any, preferences: RequestPayload['preferences']): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  // Required fields
  if (!meal.title || typeof meal.title !== 'string') errors.push('Missing or invalid title');
  if (!meal.description || typeof meal.description !== 'string') errors.push('Missing or invalid description');
  if (!meal.prepTime || typeof meal.prepTime !== 'number') errors.push('Missing or invalid prepTime');
  if (!meal.difficulty || !['Easy', 'Medium', 'Hard'].includes(meal.difficulty)) errors.push('Missing or invalid difficulty');
  if (!meal.cuisine || typeof meal.cuisine !== 'string') errors.push('Missing or invalid cuisine');
  if (!Array.isArray(meal.dietTags)) errors.push('Missing or invalid dietTags array');
  if (!Array.isArray(meal.ingredients)) errors.push('Missing or invalid ingredients array');
  if (!Array.isArray(meal.instructions)) errors.push('Missing or invalid instructions array');
  if (!meal.nutritionInfo || typeof meal.nutritionInfo !== 'object') errors.push('Missing or invalid nutritionInfo');

  // Preference validation
  if (meal.prepTime > preferences.maxCookingTime) {
    errors.push(`Prep time (${meal.prepTime}) exceeds max cooking time (${preferences.maxCookingTime})`);
  }

  if (preferences.difficultyPreference && meal.difficulty !== preferences.difficultyPreference) {
    errors.push(`Difficulty (${meal.difficulty}) doesn't match preference (${preferences.difficultyPreference})`);
  }

  if (preferences.cuisinePreferences.length > 0 && !preferences.cuisinePreferences.includes(meal.cuisine)) {
    errors.push(`Cuisine (${meal.cuisine}) not in preferences (${preferences.cuisinePreferences.join(', ')})`);
  }

  if (preferences.dietaryRestrictions.length > 0) {
    const mealTags = meal.dietTags || [];
    const hasRequiredTag = preferences.dietaryRestrictions.some(restriction => 
      mealTags.includes(restriction)
    );
    if (!hasRequiredTag) {
      errors.push(`Meal doesn't match dietary restrictions: ${preferences.dietaryRestrictions.join(', ')}`);
    }
  }

  // Excluded ingredients check
  if (preferences.excludedIngredients && preferences.excludedIngredients.length > 0) {
    const mealIngredients = meal.ingredients || [];
    const excludedFound = preferences.excludedIngredients.some(excluded => 
      mealIngredients.some((ing: any) => 
        ing.name && ing.name.toLowerCase().includes(excluded.toLowerCase())
      )
    );
    if (excludedFound) {
      errors.push(`Meal contains excluded ingredients: ${preferences.excludedIngredients.join(', ')}`);
    }
  }

  return { valid: errors.length === 0, errors };
}

// Fallback to existing database-first function
// Create a dummy meal when both AI and database fail
function createDummyMeal(payload: RequestPayload): ResponseBody {
  console.log("🔄 [Dummy] Creating safe placeholder meal");
  
  const dummyMeal = {
    id: "dummy-meal-" + Date.now(),
    title: "Simple Pasta with Olive Oil",
    description: "A basic, safe meal option when our systems are temporarily unavailable. Boil pasta, add olive oil, salt, and pepper for a simple but satisfying dish.",
    prepTime: 15,
    difficulty: "Easy",
    cuisine: "Italian",
    dietTags: ["Vegetarian"],
    imageURL: null,
    ingredients: [
      { name: "Pasta (any type)", amount: "8", unit: "oz" },
      { name: "Olive oil", amount: "3", unit: "tbsp" },
      { name: "Salt", amount: "1", unit: "tsp" },
      { name: "Black pepper", amount: "1/4", unit: "tsp" },
      { name: "Parmesan cheese (optional)", amount: "1/4", unit: "cup" }
    ],
    instructions: [
      "Bring a large pot of salted water to boil.",
      "Add pasta and cook according to package directions until al dente.",
      "Drain pasta, reserving 1/2 cup of pasta water.",
      "Return pasta to pot, add olive oil, salt, and black pepper.",
      "Toss well, adding reserved pasta water if needed for moisture.",
      "Serve immediately with optional Parmesan cheese."
    ],
    nutritionInfo: {
      calories: 450,
      protein: 15,
      carbs: 65,
      fat: 12
    }
  };

  // Scale ingredients if needed
  if (payload.preferences.servingSize && payload.preferences.servingSize !== 2) {
    dummyMeal.ingredients = scaleIngredients(dummyMeal.ingredients, payload.preferences.servingSize);
  }

  return {
    status: "ok",
    meal: dummyMeal,
    badges: [`${dummyMeal.prepTime} min`, dummyMeal.difficulty, dummyMeal.cuisine],
    alternatives: [],
    aiGenerated: false,
    fallbackUsed: true,
    cachedResult: false,
    backgroundGenerated: false
  };
}

async function fallbackToDatabase(payload: RequestPayload): Promise<ResponseBody> {
  console.log("🔄 [Fallback] Using database-first approach");
  
  const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);
  
  // Call the existing suggest_meal function logic (simplified version)
  let query = supabase
    .from("meals")
    .select("id, title, description, prep_time, difficulty, cuisine, diet_tags, image_url, ingredients, instructions, nutrition_info")
    .lte("prep_time", payload.preferences.maxCookingTime)
    .limit(25);

  if (payload.preferences.cuisinePreferences?.length) {
    query = query.in("cuisine", payload.preferences.cuisinePreferences);
  }
  if (payload.preferences.difficultyPreference) {
    query = query.eq("difficulty", payload.preferences.difficultyPreference);
  }
  if (payload.preferences.dietaryRestrictions?.length) {
    query = query.overlaps("diet_tags", payload.preferences.dietaryRestrictions);
  }
  if (payload.preferences.excludedIngredients?.length) {
    for (const ingredient of payload.preferences.excludedIngredients) {
      query = query.not("ingredients", "ilike", `%${ingredient}%`);
    }
  }
  if (payload.recentMealIds?.length) {
    query = query.not("id", "in", `(${payload.recentMealIds.join(",")})`);
  }

  const { data: rows, error } = await query;
  
  if (error) {
    console.error("🔄 [Fallback] Database query error:", error);
    return { status: "no_match", reason: "Database query failed" };
  }

  if (!rows || rows.length === 0) {
    console.log("🔄 [Fallback] No meals found in database - returning dummy meal");
    return createDummyMeal(payload);
  }

  // Random selection from database results
  const selected = rows[Math.floor(Math.random() * rows.length)];
  
  const meal = {
    id: selected.id,
    title: selected.title,
    description: selected.description,
    prepTime: selected.prep_time,
    difficulty: selected.difficulty,
    cuisine: selected.cuisine,
    dietTags: selected.diet_tags ?? [],
    imageURL: selected.image_url ?? null,
    ingredients: selected.ingredients ?? [],
    instructions: selected.instructions ?? [],
    nutritionInfo: selected.nutrition_info ?? null,
  };

  // Scale ingredients if needed
  if (payload.preferences.servingSize && payload.preferences.servingSize !== 2) {
    meal.ingredients = scaleIngredients(meal.ingredients, payload.preferences.servingSize);
  }

  return {
    status: "ok",
    meal,
    badges: [`${meal.prepTime} min`, meal.difficulty, meal.cuisine].slice(0, 3),
    alternatives: [],
    aiGenerated: false,
    fallbackUsed: true,
    cachedResult: false,
    backgroundGenerated: false
  };
}

// Scale ingredient amounts based on serving size
function scaleIngredients(ingredients: any[], targetServingSize: number): any[] {
  const defaultServingSize = 2;
  const scaleFactor = targetServingSize / defaultServingSize;
  
  return ingredients.map((ingredient: any) => {
    if (!ingredient.amount) return ingredient;
    
    const scaledAmount = scaleAmount(ingredient.amount, scaleFactor);
    
    return {
      ...ingredient,
      amount: scaledAmount
    };
  });
}

// Smart amount scaling that handles fractions and common measurements
function scaleAmount(amount: string, factor: number): string {
  const fractionMap: { [key: string]: number } = {
    '1/4': 0.25, '1/3': 0.33, '1/2': 0.5, '2/3': 0.67, '3/4': 0.75,
    '1 1/4': 1.25, '1 1/3': 1.33, '1 1/2': 1.5, '1 2/3': 1.67, '1 3/4': 1.75,
    '2 1/4': 2.25, '2 1/3': 2.33, '2 1/2': 2.5, '2 2/3': 2.67, '2 3/4': 2.75
  };
  
  if (fractionMap[amount]) {
    const scaled = fractionMap[amount] * factor;
    return formatScaledNumber(scaled);
  }
  
  const numMatch = amount.match(/^(\d+(?:\.\d+)?)/);
  if (numMatch) {
    const num = parseFloat(numMatch[1]);
    const scaled = num * factor;
    const remainder = amount.substring(numMatch[0].length);
    return formatScaledNumber(scaled) + remainder;
  }
  
  return amount;
}

// Format scaled numbers nicely
function formatScaledNumber(num: number): string {
  if (num < 0.125) return "pinch";
  if (num < 0.25) return "1/8";
  if (num < 0.375) return "1/4";
  if (num < 0.625) return "1/2";
  if (num < 0.875) return "3/4";
  if (num < 1.125) return "1";
  if (num < 1.375) return "1 1/4";
  if (num < 1.625) return "1 1/2";
  if (num < 1.875) return "1 3/4";
  
  if (num < 10) {
    return (Math.round(num * 4) / 4).toString();
  }
  
  return Math.round(num).toString();
}

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  let payload: RequestPayload;
  try {
    payload = (await req.json()) as RequestPayload;
    const startTime = Date.now();

    // Clean up expired cache entries to prevent memory leaks
    cleanupExpiredCache();

    // STEP 1: Check cache first for instant response
    const cacheKey = generateCacheKey(payload.preferences, payload.timeOfDay);
    const cachedEntry = getFromCache(cacheKey);
    
    if (cachedEntry) {
      const responseTime = Date.now() - startTime;
      console.log("🗄️ [Cache] Cache hit - response time:", responseTime + "ms");
      
      return json({
        status: "ok",
        meal: cachedEntry.meal,
        badges: cachedEntry.badges,
        alternatives: [],
        aiGenerated: true,
        fallbackUsed: false,
        cachedResult: true,
        backgroundGenerated: false
      }, 200);
    }

    // STEP 2: Try AI generation with 8s timeout to prevent slow responses
    const aiPromise = generateMealWithAI(payload);
    const timeoutPromise = new Promise<AIResponse>((_, reject) => {
      setTimeout(() => reject(new Error("AI timeout")), AI_TIMEOUT);
    });

    try {
      const aiResult = await Promise.race([aiPromise, timeoutPromise]);
      
      if (aiResult.status === "ok" && aiResult.meal) {
        const responseTime = Date.now() - startTime;
        console.log("🤖 [AI] Generation successful - response time:", responseTime + "ms");
        
        const aiMeal = aiResult.meal;
        
        // Scale ingredients based on serving size (default is 2 people)
        let scaledIngredients = aiMeal.ingredients;
        if (payload.preferences.servingSize && payload.preferences.servingSize !== 2) {
          scaledIngredients = scaleIngredients(aiMeal.ingredients, payload.preferences.servingSize);
        }

        const meal = {
          id: aiMeal.id,
          title: aiMeal.title,
          description: aiMeal.description,
          prepTime: aiMeal.prepTime,
          difficulty: aiMeal.difficulty,
          cuisine: aiMeal.cuisine,
          dietTags: aiMeal.dietTags,
          imageURL: aiMeal.imageURL || null,
          ingredients: scaledIngredients,
          instructions: aiMeal.instructions,
          nutritionInfo: aiMeal.nutritionInfo,
        };

        const badges = [`${aiMeal.prepTime} min`, aiMeal.difficulty, aiMeal.cuisine].slice(0, 3);
        
        // ❌ REMOVED: No caching for AI meals - fresh suggestions every time
        // saveToCache(cacheKey, meal, badges);

        return json({
          status: "ok",
          meal,
          badges,
          alternatives: [],
          aiGenerated: true,
          fallbackUsed: false,
          cachedResult: false,
          backgroundGenerated: false
        }, 200);
      }
    } catch (timeoutError) {
      console.log("⏱️ [Timeout] AI generation exceeded", AI_TIMEOUT + "ms, using database fallback");
      
      // Continue AI generation in background for future cache hits
      aiPromise.then((aiResult) => {
        if (aiResult.status === "ok" && aiResult.meal) {
          console.log("🔄 [Background] AI completed, caching for future requests");
          const aiMeal = aiResult.meal;
          
          // Scale ingredients based on serving size
          let scaledIngredients = aiMeal.ingredients;
          if (payload.preferences.servingSize && payload.preferences.servingSize !== 2) {
            scaledIngredients = scaleIngredients(aiMeal.ingredients, payload.preferences.servingSize);
          }

          const meal = {
            id: aiMeal.id,
            title: aiMeal.title,
            description: aiMeal.description,
            prepTime: aiMeal.prepTime,
            difficulty: aiMeal.difficulty,
            cuisine: aiMeal.cuisine,
            dietTags: aiMeal.dietTags,
            imageURL: aiMeal.imageURL || null,
            ingredients: scaledIngredients,
            instructions: aiMeal.instructions,
            nutritionInfo: aiMeal.nutritionInfo,
          };

          const badges = [`${aiMeal.prepTime} min`, aiMeal.difficulty, aiMeal.cuisine].slice(0, 3);
          // ❌ REMOVED: No caching for AI meals - fresh suggestions every time
          // saveToCache(cacheKey, meal, badges);
        }
      }).catch((error) => {
        console.log("🔄 [Background] AI generation failed:", error.message);
      });
    }

    // STEP 3: Use database fallback when AI fails or times out
    
    const fallbackResult = await fallbackToDatabase(payload);
    const responseTime = Date.now() - startTime;
    console.log("🔄 [Fallback] Database response time:", responseTime + "ms");
    
    if (fallbackResult.status === "ok") {
      return json({
        ...fallbackResult,
        reason: `AI generation failed or timed out. Using database fallback.`,
        cachedResult: false,
        backgroundGenerated: true
      }, 200);
    }

    // STEP 4: Both AI and database failed - return dummy meal
    console.error("❌ [Error] Both AI and database approaches failed - returning dummy meal");
    const dummyResult = createDummyMeal(payload);
    return json({
      ...dummyResult,
      reason: `AI generation failed. Database fallback also failed. Using safe placeholder meal.`
    }, 200);

  } catch (err) {
    console.error("❌ [Error] Unexpected error in AI-first function:", err);
    return json({ 
      status: "no_match", 
      reason: "Server error - unable to process request",
      cachedResult: false,
      backgroundGenerated: false
    }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
