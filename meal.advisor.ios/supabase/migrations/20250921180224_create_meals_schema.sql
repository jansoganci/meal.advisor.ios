-- Create meals schema for iOS meal advisor app
-- Based on Meal.swift model

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE difficulty_level AS ENUM ('Easy', 'Medium', 'Hard');
CREATE TYPE cuisine_type AS ENUM ('Italian', 'American', 'Asian', 'Mediterranean', 'Mexican');
CREATE TYPE diet_type AS ENUM (
    'Vegetarian', 
    'Vegan', 
    'Gluten-Free', 
    'Dairy-Free', 
    'Low-Carb', 
    'High-Protein', 
    'Paleo', 
    'Low-Sodium', 
    'Quick & Easy'
);

-- Main meals table
CREATE TABLE meals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    prep_time INTEGER NOT NULL, -- minutes
    difficulty difficulty_level NOT NULL,
    cuisine cuisine_type NOT NULL,
    diet_tags diet_type[] DEFAULT '{}', -- array of diet types
    image_url TEXT,
    ingredients JSONB DEFAULT '[]', -- JSON array of ingredients
    instructions JSONB DEFAULT '[]', -- JSON array of instruction steps
    nutrition_info JSONB, -- JSON object with calories, protein, carbs, fat
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_meals_prep_time ON meals(prep_time);
CREATE INDEX idx_meals_difficulty ON meals(difficulty);
CREATE INDEX idx_meals_cuisine ON meals(cuisine);
CREATE INDEX idx_meals_diet_tags ON meals USING GIN(diet_tags);

-- User preferences table (optional, for future use)
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID, -- can be linked to auth.users later
    dietary_restrictions diet_type[] DEFAULT '{}',
    cuisine_preferences cuisine_type[] DEFAULT '{}',
    max_cooking_time INTEGER DEFAULT 60,
    difficulty_preference difficulty_level,
    excluded_ingredients TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample data for testing
INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES
(
    'Spaghetti Carbonara',
    'Classic Italian pasta dish with eggs, cheese, and pancetta',
    20,
    'Medium',
    'Italian',
    ARRAY['High-Protein']::diet_type[],
    '[
        {"name": "Spaghetti", "amount": "400", "unit": "g"},
        {"name": "Pancetta", "amount": "150", "unit": "g"},
        {"name": "Eggs", "amount": "3", "unit": "pieces"},
        {"name": "Parmesan cheese", "amount": "100", "unit": "g"},
        {"name": "Black pepper", "amount": "1", "unit": "tsp"}
    ]'::jsonb,
    '[
        "Boil water in a large pot and cook spaghetti according to package instructions",
        "Cut pancetta into small cubes and cook in a pan until crispy",
        "Beat eggs with grated parmesan and black pepper in a bowl",
        "Drain pasta and immediately mix with pancetta",
        "Remove from heat and quickly stir in egg mixture",
        "Serve immediately with extra parmesan"
    ]'::jsonb,
    '{"calories": 520, "protein": 28, "carbs": 65, "fat": 18}'::jsonb
),
(
    'Chicken Stir Fry',
    'Quick and healthy Asian-style chicken with vegetables',
    15,
    'Easy',
    'Asian',
    ARRAY['High-Protein', 'Quick & Easy']::diet_type[],
    '[
        {"name": "Chicken breast", "amount": "300", "unit": "g"},
        {"name": "Bell peppers", "amount": "2", "unit": "pieces"},
        {"name": "Broccoli", "amount": "200", "unit": "g"},
        {"name": "Soy sauce", "amount": "3", "unit": "tbsp"},
        {"name": "Garlic", "amount": "2", "unit": "cloves"},
        {"name": "Ginger", "amount": "1", "unit": "tsp"}
    ]'::jsonb,
    '[
        "Cut chicken into bite-sized pieces",
        "Heat oil in a wok or large pan",
        "Cook chicken until golden brown",
        "Add vegetables and stir fry for 3-4 minutes",
        "Add soy sauce, garlic, and ginger",
        "Serve hot with rice"
    ]'::jsonb,
    '{"calories": 280, "protein": 35, "carbs": 12, "fat": 8}'::jsonb
),
(
    'Greek Salad',
    'Fresh Mediterranean salad with feta cheese and olives',
    10,
    'Easy',
    'Mediterranean',
    ARRAY['Vegetarian', 'Gluten-Free', 'Quick & Easy']::diet_type[],
    '[
        {"name": "Cucumber", "amount": "1", "unit": "large"},
        {"name": "Tomatoes", "amount": "3", "unit": "medium"},
        {"name": "Red onion", "amount": "1/2", "unit": "medium"},
        {"name": "Feta cheese", "amount": "150", "unit": "g"},
        {"name": "Kalamata olives", "amount": "100", "unit": "g"},
        {"name": "Olive oil", "amount": "3", "unit": "tbsp"},
        {"name": "Oregano", "amount": "1", "unit": "tsp"}
    ]'::jsonb,
    '[
        "Chop cucumber, tomatoes, and red onion",
        "Combine vegetables in a large bowl",
        "Add crumbled feta cheese and olives",
        "Drizzle with olive oil and sprinkle oregano",
        "Toss gently and serve immediately"
    ]'::jsonb,
    '{"calories": 220, "protein": 8, "carbs": 15, "fat": 16}'::jsonb
),
(
    'Beef Tacos',
    'Mexican-style soft tacos with seasoned ground beef',
    25,
    'Easy',
    'Mexican',
    ARRAY['High-Protein', 'Dairy-Free']::diet_type[],
    '[
        {"name": "Ground beef", "amount": "500", "unit": "g"},
        {"name": "Taco seasoning", "amount": "1", "unit": "packet"},
        {"name": "Soft tortillas", "amount": "8", "unit": "pieces"},
        {"name": "Lettuce", "amount": "1", "unit": "head"},
        {"name": "Tomatoes", "amount": "2", "unit": "medium"},
        {"name": "Onion", "amount": "1", "unit": "medium"},
        {"name": "Lime", "amount": "2", "unit": "pieces"}
    ]'::jsonb,
    '[
        "Cook ground beef in a large skillet until browned",
        "Add taco seasoning and water according to packet instructions",
        "Simmer for 10 minutes until sauce thickens",
        "Warm tortillas in microwave or dry pan",
        "Chop lettuce, tomatoes, and onion",
        "Serve beef in tortillas with toppings and lime wedges"
    ]'::jsonb,
    '{"calories": 380, "protein": 25, "carbs": 28, "fat": 18}'::jsonb
),
(
    'Quinoa Buddha Bowl',
    'Healthy vegan bowl with quinoa, roasted vegetables, and tahini dressing',
    35,
    'Medium',
    'Mediterranean',
    ARRAY['Vegan', 'Gluten-Free', 'High-Protein', 'Low-Sodium']::diet_type[],
    '[
        {"name": "Quinoa", "amount": "1", "unit": "cup"},
        {"name": "Sweet potato", "amount": "1", "unit": "large"},
        {"name": "Chickpeas", "amount": "400", "unit": "g"},
        {"name": "Spinach", "amount": "100", "unit": "g"},
        {"name": "Avocado", "amount": "1", "unit": "medium"},
        {"name": "Tahini", "amount": "3", "unit": "tbsp"},
        {"name": "Lemon juice", "amount": "2", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Cook quinoa according to package instructions",
        "Cube sweet potato and roast at 200°C for 25 minutes",
        "Drain and rinse chickpeas, season and roast for 15 minutes",
        "Mix tahini with lemon juice and water to make dressing",
        "Arrange quinoa, vegetables, and chickpeas in bowl",
        "Top with avocado slices and drizzle with dressing"
    ]'::jsonb,
    '{"calories": 420, "protein": 18, "carbs": 58, "fat": 16}'::jsonb
);

-- Enable Row Level Security (RLS)
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access to meals
CREATE POLICY "Meals are viewable by everyone" ON meals
    FOR SELECT USING (true);

-- Create policies for user preferences (authenticated users only)
CREATE POLICY "Users can view own preferences" ON user_preferences
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences" ON user_preferences
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences" ON user_preferences
    FOR UPDATE USING (auth.uid() = user_id);

