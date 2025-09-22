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

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const payload = (await req.json()) as RequestPayload;

    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

    // 1) Filter candidates server-side (basic filters to reduce token usage)
    let query = supabase
      .from("meals")
      .select(
        "id, title, description, prep_time, difficulty, cuisine, diet_tags, image_url, ingredients, instructions, nutrition_info"
      )
      .lte("prep_time", payload.preferences.maxCookingTime)
      .limit(25);

    if (payload.preferences.cuisinePreferences?.length) {
      query = query.in("cuisine", payload.preferences.cuisinePreferences);
    }
    if (payload.preferences.difficultyPreference) {
      query = query.eq("difficulty", payload.preferences.difficultyPreference);
    }
    if (payload.recentMealIds?.length) {
      query = query.not("id", "in", `(${payload.recentMealIds.map((x) => `'${x}'`).join(",")})`);
    }

    const { data: rows, error } = await query;
    if (error) throw error;

    // If no rows, return early with no_match
    if (!rows || rows.length === 0) {
      const body: ResponseBody = { status: "no_match", reason: "No candidates found" };
      return json(body, 200);
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
    const decision = GEMINI_API_KEY
      ? await callGemini(payload, candidates, GEMINI_API_KEY)
      : ({ status: "ok", selectedMealId: candidates[0].id, badges: ["Quick & Easy"], alternatives: candidates.slice(1, 4).map(c => c.id) } as GeminiDecision);

    if (decision.status !== "ok" || !decision.selectedMealId) {
      const body: ResponseBody = { status: "no_match", reason: decision.reason ?? "No suitable suggestion" };
      return json(body, 200);
    }

    // 4) Return full meal row (already selected) + badges/alternatives
    const selected = rows.find((r: any) => r.id === decision.selectedMealId) ?? rows[0];

    // Ensure keys match iOS model (camelCase)
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

async function callGemini(payload: RequestPayload, candidates: Candidate[], apiKey: string): Promise<GeminiDecision> {
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${apiKey}`;

  const system = `You are a meal suggestion assistant for an iOS app. Choose ONE meal from provided candidates.
Rules:
- Obey allergies/dislikes and excluded ingredients.
- Prefer cuisines and diet tags the user likes.
- Respect max cooking time and difficulty preference.
- Avoid recently shown meals.
- Consider time of day for meal period.
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
  try {
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "{}";
    const parsed = JSON.parse(text);
    // Basic sanity check: selectedMealId present when ok
    if (parsed.status === "ok" && !parsed.selectedMealId) {
      return { status: "no_match", reason: "No selection provided" };
    }
    return parsed as GeminiDecision;
  } catch (_e) {
    return { status: "no_match", reason: "Invalid JSON from model" };
  }
}

