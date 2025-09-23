// supabase/functions/suggest_meal/index.ts
// Edge Function: Rerank meals with Gemini and return a structured suggestion
// Runtime: Deno

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

type Candidate = {
  id: string;
  title: string;
  description: string;
  prepTime: number;
  difficulty: string;
  cuisine: string;
  dietTags: string[];
};

type GeminiDecision = {
  status: "ok" | "no_match";
  selectedMealId?: string;
  alternatives?: string[];
  badges?: string[];
  reason?: string;
};

type ResponseBody = {
  meal?: any; // full row mapped to app shape
  badges?: string[];
  alternatives?: string[];
  reason?: string;
  status: "ok" | "no_match";
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Missing Supabase env vars");
}

// Smart fallback when strict preferences return no results
async function tryFallbackQuery(supabase: any, preferences: any) {
  console.log("🍽️ [EdgeFunction] Trying fallback query with relaxed constraints");
  
  // Priority order for constraint relaxation:
  // 1. Keep dietary restrictions (most important for health/ethics)
  // 2. Keep cuisine preferences (strong taste preference)  
  // 3. Relax cooking time (can be flexible)
  // 4. Relax difficulty (can learn new skills)
  
  // Fallback 1: Relax cooking time by 50%
  let fallbackQuery = supabase
    .from("meals")
    .select("id, title, description, prep_time, difficulty, cuisine, diet_tags, image_url, ingredients, instructions, nutrition_info")
    .lte("prep_time", Math.ceil(Math.min(preferences.maxCookingTime * 1.5, 120))) // Max 2 hours, rounded up
    .limit(25);
    
  // Keep dietary restrictions (critical)
  if (preferences.dietaryRestrictions?.length) {
    fallbackQuery = fallbackQuery.overlaps("diet_tags", preferences.dietaryRestrictions);
  }
  
  // Keep cuisine preferences (important)
  if (preferences.cuisinePreferences?.length) {
    fallbackQuery = fallbackQuery.in("cuisine", preferences.cuisinePreferences);
  }
  
  // Keep excluded ingredients (health/allergy safety)
  if (preferences.excludedIngredients?.length) {
    for (const ingredient of preferences.excludedIngredients) {
      fallbackQuery = fallbackQuery.not("ingredients", "ilike", `%${ingredient}%`);
    }
  }
  
  // Skip difficulty preference in fallback (most flexible)
  
  const { data: fallbackRows, error: fallbackError } = await fallbackQuery;
  
  if (fallbackError) {
    console.log("🍽️ [EdgeFunction] Fallback query error:", fallbackError);
    return null;
  }
  
  if (fallbackRows && fallbackRows.length > 0) {
    console.log(`🍽️ [EdgeFunction] Fallback 1 (relaxed time) found ${fallbackRows.length} meals`);
    return fallbackRows;
  }
  
  // Fallback 2: Further relax by removing cuisine restriction
  console.log("🍽️ [EdgeFunction] Trying fallback 2: removing cuisine restriction");
  
  let fallback2Query = supabase
    .from("meals")
    .select("id, title, description, prep_time, difficulty, cuisine, diet_tags, image_url, ingredients, instructions, nutrition_info")
    .lte("prep_time", Math.ceil(Math.min(preferences.maxCookingTime * 2, 120)))
    .limit(25);
    
  // Keep only dietary restrictions (most critical)
  if (preferences.dietaryRestrictions?.length) {
    fallback2Query = fallback2Query.overlaps("diet_tags", preferences.dietaryRestrictions);
  }
  
  // Keep excluded ingredients (safety)
  if (preferences.excludedIngredients?.length) {
    for (const ingredient of preferences.excludedIngredients) {
      fallback2Query = fallback2Query.not("ingredients", "ilike", `%${ingredient}%`);
    }
  }
  
  const { data: fallback2Rows, error: fallback2Error } = await fallback2Query;
  
  if (fallback2Error) {
    console.log("🍽️ [EdgeFunction] Fallback 2 query error:", fallback2Error);
    return null;
  }
  
  if (fallback2Rows && fallback2Rows.length > 0) {
    console.log(`🍽️ [EdgeFunction] Fallback 2 (relaxed time + cuisine) found ${fallback2Rows.length} meals`);
    return fallback2Rows;
  }
  
  console.log("🍽️ [EdgeFunction] All fallback attempts failed");
  return null;
}

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const payload = (await req.json()) as RequestPayload;
    
    console.log("🍽️ [EdgeFunction] Received preferences:", JSON.stringify(payload.preferences, null, 2));

    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

    // 1) Filter candidates server-side (basic filters to reduce token usage)
    let query = supabase
      .from("meals")
      .select(
        "id, title, description, prep_time, difficulty, cuisine, diet_tags, image_url, ingredients, instructions, nutrition_info"
      )
      .lte("prep_time", payload.preferences.maxCookingTime)
      .limit(25);
      
    console.log("🍽️ [EdgeFunction] Base query with cooking time filter: prep_time <= ", payload.preferences.maxCookingTime);

    if (payload.preferences.cuisinePreferences?.length) {
      console.log("🍽️ [EdgeFunction] Filtering by cuisines:", payload.preferences.cuisinePreferences);
      query = query.in("cuisine", payload.preferences.cuisinePreferences);
    }
    if (payload.preferences.difficultyPreference) {
      console.log("🍽️ [EdgeFunction] Filtering by difficulty:", payload.preferences.difficultyPreference);
      query = query.eq("difficulty", payload.preferences.difficultyPreference);
    }
    
    // NEW: Filter by dietary restrictions
    if (payload.preferences.dietaryRestrictions?.length) {
      console.log("🍽️ [EdgeFunction] Filtering by dietary restrictions:", payload.preferences.dietaryRestrictions);
      // Use PostgreSQL array overlap operator to find meals that match dietary restrictions
      query = query.overlaps("diet_tags", payload.preferences.dietaryRestrictions);
    }
    
    // NEW: Exclude meals with unwanted ingredients
    if (payload.preferences.excludedIngredients?.length) {
      console.log("🍽️ [EdgeFunction] Excluding ingredients:", payload.preferences.excludedIngredients);
      // For each excluded ingredient, filter out meals that contain it
      for (const ingredient of payload.preferences.excludedIngredients) {
        query = query.not("ingredients", "ilike", `%${ingredient}%`);
      }
    }
    
    if (payload.recentMealIds?.length) {
      console.log(`🍽️ [EdgeFunction] Excluding recent meal IDs: ${payload.recentMealIds.join(', ')}`);
      query = query.not("id", "in", `(${payload.recentMealIds.join(",")})`);
    }

    let { data: rows, error } = await query;
    if (error) {
      console.log("🍽️ [EdgeFunction] Database query error:", error);
      throw error;
    }

    console.log(`🍽️ [EdgeFunction] Query returned ${rows?.length || 0} meals after filtering`);

    // If no rows, try smart fallback with relaxed constraints
    if (!rows || rows.length === 0) {
      console.log("🍽️ [EdgeFunction] No meals found matching strict preferences, trying fallback...");
      
      const fallbackRows = await tryFallbackQuery(supabase, payload.preferences);
      if (fallbackRows && fallbackRows.length > 0) {
        console.log(`🍽️ [EdgeFunction] Fallback query found ${fallbackRows.length} meals`);
        // Use fallback results
        rows = fallbackRows;
      } else {
        console.log("🍽️ [EdgeFunction] Even fallback query found no meals");
        const body: ResponseBody = { status: "no_match", reason: "No meals found even with relaxed preferences" };
        return json(body, 200);
      }
    }

    // 2) Prepare compact candidate list for LLM
    const candidates: Candidate[] = rows.map((r: any) => ({
      id: r.id,
      title: r.title,
      description: r.description,
      prepTime: r.prep_time,
      difficulty: r.difficulty,
      cuisine: r.cuisine,
      dietTags: r.diet_tags ?? [],
    }));

    // 3) Ask Gemini to choose best suggestion with structured output
    console.log(`🍽️ [EdgeFunction] Gemini API Key present: ${GEMINI_API_KEY ? 'YES' : 'NO'}`);
    console.log(`🍽️ [EdgeFunction] Candidates available: ${candidates.length}`);
    console.log(`🍽️ [EdgeFunction] First few candidate IDs: ${candidates.slice(0, 3).map(c => c.id).join(', ')}`);
    
    const decision = GEMINI_API_KEY
      ? await callGemini(payload, candidates, GEMINI_API_KEY)
      : ({ 
          status: "ok", 
          selectedMealId: candidates[Math.floor(Math.random() * candidates.length)].id, // Random selection
          badges: ["Quick & Easy"], 
          alternatives: candidates.slice(1, 4).map(c => c.id) 
        } as GeminiDecision);
    
    console.log(`🍽️ [EdgeFunction] Decision made - Selected meal ID: ${decision.selectedMealId}`);

    if (decision.status !== "ok" || !decision.selectedMealId) {
      const body: ResponseBody = { status: "no_match", reason: decision.reason ?? "No suitable suggestion" };
      return json(body, 200);
    }

    // 4) Return full meal row (already selected) + badges/alternatives
    const selected = rows.find((r: any) => r.id === decision.selectedMealId) ?? rows[0];

    // Ensure keys match iOS model (camelCase)
    let meal = {
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

    // Scale ingredients based on serving size (assuming recipes are for 2 people by default)
    if (payload.preferences.servingSize && payload.preferences.servingSize !== 2) {
      console.log(`🍽️ [EdgeFunction] Scaling ingredients for ${payload.preferences.servingSize} people (from default 2)`);
      meal = scaleIngredients(meal, payload.preferences.servingSize);
    }

    const body: ResponseBody = {
      status: "ok",
      meal,
      badges: decision.badges ?? defaultBadges(meal),
      alternatives: decision.alternatives ?? [],
      reason: decision.reason,
    };
    return json(body, 200);
  } catch (err) {
    console.error(err);
    return json({ status: "no_match", reason: "Server error" }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function defaultBadges(meal: any): string[] {
  const out: string[] = [];
  out.push(`${meal.prepTime} min`);
  if (meal.difficulty) out.push(meal.difficulty);
  if (meal.cuisine) out.push(meal.cuisine);
  return out.slice(0, 3);
}

// Scale ingredient amounts based on serving size
function scaleIngredients(meal: any, targetServingSize: number): any {
  const defaultServingSize = 2; // Assume recipes are for 2 people by default
  const scaleFactor = targetServingSize / defaultServingSize;
  
  console.log(`🍽️ [EdgeFunction] Scaling factor: ${scaleFactor} (${targetServingSize}/${defaultServingSize})`);
  
  if (!meal.ingredients || !Array.isArray(meal.ingredients)) {
    return meal;
  }
  
  const scaledIngredients = meal.ingredients.map((ingredient: any) => {
    if (!ingredient.amount) return ingredient;
    
    const scaledAmount = scaleAmount(ingredient.amount, scaleFactor);
    
    return {
      ...ingredient,
      amount: scaledAmount
    };
  });
  
  // Scale nutrition info proportionally
  let scaledNutrition = meal.nutritionInfo;
  if (scaledNutrition && typeof scaledNutrition === 'object') {
    scaledNutrition = {
      calories: scaledNutrition.calories ? Math.round(scaledNutrition.calories * scaleFactor) : null,
      protein: scaledNutrition.protein ? Math.round(scaledNutrition.protein * scaleFactor) : null,
      carbs: scaledNutrition.carbs ? Math.round(scaledNutrition.carbs * scaleFactor) : null,
      fat: scaledNutrition.fat ? Math.round(scaledNutrition.fat * scaleFactor) : null,
    };
  }
  
  return {
    ...meal,
    ingredients: scaledIngredients,
    nutritionInfo: scaledNutrition
  };
}

// Smart amount scaling that handles fractions and common measurements
function scaleAmount(amount: string, factor: number): string {
  // Handle common fractions
  const fractionMap: { [key: string]: number } = {
    '1/4': 0.25, '1/3': 0.33, '1/2': 0.5, '2/3': 0.67, '3/4': 0.75,
    '1 1/4': 1.25, '1 1/3': 1.33, '1 1/2': 1.5, '1 2/3': 1.67, '1 3/4': 1.75,
    '2 1/4': 2.25, '2 1/3': 2.33, '2 1/2': 2.5, '2 2/3': 2.67, '2 3/4': 2.75
  };
  
  // Check if amount is a known fraction
  if (fractionMap[amount]) {
    const scaled = fractionMap[amount] * factor;
    return formatScaledNumber(scaled);
  }
  
  // Try to parse as number
  const numMatch = amount.match(/^(\d+(?:\.\d+)?)/);
  if (numMatch) {
    const num = parseFloat(numMatch[1]);
    const scaled = num * factor;
    const remainder = amount.substring(numMatch[0].length);
    return formatScaledNumber(scaled) + remainder;
  }
  
  // If we can't parse it, return as-is
  return amount;
}

// Format scaled numbers nicely
function formatScaledNumber(num: number): string {
  // Round to reasonable precision
  if (num < 0.125) return "pinch";
  if (num < 0.25) return "1/8";
  if (num < 0.375) return "1/4";
  if (num < 0.625) return "1/2";
  if (num < 0.875) return "3/4";
  if (num < 1.125) return "1";
  if (num < 1.375) return "1 1/4";
  if (num < 1.625) return "1 1/2";
  if (num < 1.875) return "1 3/4";
  
  // For larger numbers, round to 1 decimal place
  if (num < 10) {
    return (Math.round(num * 4) / 4).toString(); // Round to nearest 1/4
  }
  
  return Math.round(num).toString();
}

async function callGemini(payload: RequestPayload, candidates: Candidate[], apiKey: string): Promise<GeminiDecision> {
  console.log(`🍽️ [Gemini] Calling Gemini API with ${candidates.length} candidates`);
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${apiKey}`;

  const system = `You are a meal suggestion assistant for an iOS app. Choose ONE meal from provided candidates.
Rules:
- Obey allergies/dislikes and excluded ingredients.
- Prefer cuisines and diet tags the user likes.
- Respect max cooking time and difficulty preference.
- Avoid recently shown meals.
- Consider time of day for meal period.
- IMPORTANT: Vary your selections to provide diverse meal experiences.
- Don't always pick the "most optimal" meal - sometimes choose interesting alternatives.
- Consider factors like cooking method variety, ingredient diversity, and flavor profiles.
- Add some randomness to your choices to keep suggestions fresh and exciting.
- Output strictly in the provided JSON schema.
- selectedMealId MUST be one of the provided candidate ids.
`;

  const user = {
    locale: payload.locale ?? "en",
    timeOfDay: payload.timeOfDay ?? null,
    preferences: payload.preferences,
    recentMealIds: payload.recentMealIds ?? [],
    ingredientHint: payload.ingredientHint ?? null,
    candidates,
    timestamp: new Date().toISOString(), // Add uniqueness to each request
    requestId: Math.random().toString(36).substring(2, 15), // Random request ID
  };

  const responseSchema = {
    type: "object",
    properties: {
      status: { type: "string", enum: ["ok", "no_match"] },
      selectedMealId: { type: "string", nullable: true },
      alternatives: { type: "array", items: { type: "string" } },
      badges: { type: "array", items: { type: "string" } },
      reason: { type: "string" },
    },
    required: ["status"],
  } as const;

  const body = {
    contents: [
      { role: "user", parts: [{ text: system }] },
      { role: "user", parts: [{ text: `User + candidates JSON:\n\n${JSON.stringify(user)}` }] },
    ],
    generationConfig: {
      response_mime_type: "application/json",
      response_schema: responseSchema,
      temperature: 0.4,
      top_p: 0.9,
    },
  };

  const res = await fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    console.error("Gemini error", await res.text());
    return { status: "no_match", reason: "LLM call failed" };
  }

  const data = await res.json();
  console.log(`🍽️ [Gemini] Response received:`, JSON.stringify(data, null, 2));
  
  try {
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "{}";
    console.log(`🍽️ [Gemini] Extracted text:`, text);
    const parsed = JSON.parse(text);
    console.log(`🍽️ [Gemini] Parsed decision:`, parsed);
    
    // Basic sanity check: selectedMealId present when ok
    if (parsed.status === "ok" && !parsed.selectedMealId) {
      console.log(`🍽️ [Gemini] Warning: Status OK but no selectedMealId`);
      return { status: "no_match", reason: "No selection provided" };
    }
    return parsed as GeminiDecision;
  } catch (_e) {
    return { status: "no_match", reason: "Invalid JSON from model" };
  }
}

