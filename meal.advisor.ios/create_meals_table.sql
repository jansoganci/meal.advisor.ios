-- Simple meals table for testing
-- Run this in Supabase SQL Editor

CREATE TABLE meals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    prep_time INTEGER NOT NULL,
    difficulty TEXT NOT NULL,
    cuisine TEXT NOT NULL,
    diet_tags TEXT[] DEFAULT '{}',
    image_url TEXT,
    ingredients JSONB DEFAULT '[]',
    instructions JSONB DEFAULT '[]',
    nutrition_info JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert test data
INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES
(
    'Spaghetti Carbonara',
    'Classic Italian pasta dish with eggs, cheese, and pancetta',
    20,
    'Medium',
    'Italian',
    ARRAY['High-Protein'],
    '[
        {"name": "Spaghetti", "amount": "400", "unit": "g"},
        {"name": "Pancetta", "amount": "150", "unit": "g"},
        {"name": "Eggs", "amount": "3", "unit": "pieces"},
        {"name": "Parmesan cheese", "amount": "100", "unit": "g"}
    ]'::jsonb,
    '[
        "Boil water and cook spaghetti",
        "Cook pancetta until crispy", 
        "Mix eggs with parmesan",
        "Combine all ingredients"
    ]'::jsonb,
    '{"calories": 520, "protein": 28, "carbs": 65, "fat": 18}'::jsonb
),
(
    'Chicken Stir Fry',
    'Quick Asian-style chicken with vegetables',
    15,
    'Easy',
    'Asian',
    ARRAY['High-Protein', 'Quick & Easy'],
    '[
        {"name": "Chicken breast", "amount": "300", "unit": "g"},
        {"name": "Bell peppers", "amount": "2", "unit": "pieces"},
        {"name": "Soy sauce", "amount": "3", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Cut chicken into pieces",
        "Heat oil in wok",
        "Cook chicken and vegetables",
        "Add soy sauce and serve"
    ]'::jsonb,
    '{"calories": 280, "protein": 35, "carbs": 12, "fat": 8}'::jsonb
),
(
    'Greek Salad',
    'Fresh Mediterranean salad with feta',
    10,
    'Easy',
    'Mediterranean', 
    ARRAY['Vegetarian', 'Gluten-Free'],
    '[
        {"name": "Cucumber", "amount": "1", "unit": "large"},
        {"name": "Tomatoes", "amount": "3", "unit": "medium"},
        {"name": "Feta cheese", "amount": "150", "unit": "g"}
    ]'::jsonb,
    '[
        "Chop vegetables",
        "Add feta and olives",
        "Drizzle with olive oil"
    ]'::jsonb,
    '{"calories": 220, "protein": 8, "carbs": 15, "fat": 16}'::jsonb
);

-- Enable public access
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Meals are viewable by everyone" ON meals FOR SELECT USING (true);

