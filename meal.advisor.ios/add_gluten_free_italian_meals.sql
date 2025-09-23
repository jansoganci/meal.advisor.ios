-- ADD GLUTEN-FREE ITALIAN MEALS
-- Fixes the database content gap for Gluten-Free Italian cuisine preferences

INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES 
(
    'Gluten-Free Chicken Marsala',
    'Tender chicken breasts in a rich Marsala wine sauce with mushrooms and herbs, served over gluten-free pasta or rice. Classic Italian flavors without the gluten.',
    30,
    'Medium',
    'Italian',
    ARRAY['High-Protein', 'Gluten-Free']::text[],
    '[
        {"name": "Chicken breasts", "amount": "2", "unit": "large"},
        {"name": "Gluten-free flour", "amount": "1/2", "unit": "cup"},
        {"name": "Marsala wine", "amount": "1/2", "unit": "cup"},
        {"name": "Chicken broth", "amount": "1/4", "unit": "cup"},
        {"name": "Cremini mushrooms", "amount": "8", "unit": "oz"},
        {"name": "Butter", "amount": "3", "unit": "tbsp"},
        {"name": "Fresh thyme", "amount": "1", "unit": "tsp"},
        {"name": "Gluten-free pasta", "amount": "8", "unit": "oz"}
    ]'::jsonb,
    '[
        "Pound chicken to 1/2 inch thickness and season with salt and pepper",
        "Dredge chicken in gluten-free flour, shaking off excess",
        "Heat butter in large skillet, cook chicken 4-5 minutes per side",
        "Remove chicken, add mushrooms and cook until golden",
        "Add Marsala wine, broth, and thyme, simmer until reduced",
        "Return chicken to pan, cook 2 minutes until heated through",
        "Serve over cooked gluten-free pasta"
    ]'::jsonb,
    '{"calories": 480, "protein": 38, "carbs": 32, "fat": 18}'::jsonb
),
(
    'Gluten-Free Caprese Risotto',
    'Creamy Arborio rice with fresh tomatoes, mozzarella, and basil. A gluten-free twist on classic Italian risotto that''s rich, comforting, and naturally gluten-free.',
    35,
    'Medium',
    'Italian',
    ARRAY['Vegetarian', 'Gluten-Free']::text[],
    '[
        {"name": "Arborio rice", "amount": "1.5", "unit": "cups"},
        {"name": "Vegetable broth", "amount": "4", "unit": "cups"},
        {"name": "Cherry tomatoes", "amount": "1", "unit": "pint"},
        {"name": "Fresh mozzarella", "amount": "8", "unit": "oz"},
        {"name": "Fresh basil", "amount": "1/2", "unit": "cup"},
        {"name": "Parmesan cheese", "amount": "1/2", "unit": "cup"},
        {"name": "White wine", "amount": "1/2", "unit": "cup"},
        {"name": "Olive oil", "amount": "2", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Heat broth in saucepan, keep warm over low heat",
        "Sauté rice in olive oil for 2 minutes until translucent",
        "Add wine, stir until absorbed",
        "Add warm broth 1/2 cup at a time, stirring constantly",
        "When rice is almost tender, add halved cherry tomatoes",
        "Stir in mozzarella and basil, cook 2 minutes more",
        "Finish with Parmesan cheese and serve immediately"
    ]'::jsonb,
    '{"calories": 420, "protein": 16, "carbs": 58, "fat": 14}'::jsonb
),
(
    'Gluten-Free Eggplant Parmesan',
    'Layers of breaded eggplant, marinara sauce, and melted cheese, all gluten-free. A hearty vegetarian Italian classic that''s crispy, cheesy, and completely gluten-free.',
    40,
    'Medium',
    'Italian',
    ARRAY['Vegetarian', 'Gluten-Free']::text[],
    '[
        {"name": "Large eggplant", "amount": "2", "unit": "medium"},
        {"name": "Gluten-free breadcrumbs", "amount": "1", "unit": "cup"},
        {"name": "Parmesan cheese", "amount": "1/2", "unit": "cup"},
        {"name": "Eggs", "amount": "2", "unit": "large"},
        {"name": "Marinara sauce", "amount": "2", "unit": "cups"},
        {"name": "Mozzarella cheese", "amount": "1.5", "unit": "cups"},
        {"name": "Fresh basil", "amount": "1/4", "unit": "cup"},
        {"name": "Olive oil", "amount": "1/3", "unit": "cup"}
    ]'::jsonb,
    '[
        "Slice eggplant 1/2 inch thick, salt and let sit 30 minutes",
        "Rinse eggplant and pat dry",
        "Set up breading: flour, beaten eggs, breadcrumb-Parmesan mix",
        "Bread eggplant slices, fry in olive oil until golden",
        "Layer in baking dish: sauce, eggplant, mozzarella, repeat",
        "Top with remaining cheese and basil",
        "Bake at 375°F for 25 minutes until bubbly"
    ]'::jsonb,
    '{"calories": 380, "protein": 18, "carbs": 28, "fat": 22}'::jsonb
),
(
    'Gluten-Free Pesto Zucchini Noodles',
    'Fresh zucchini noodles tossed with homemade basil pesto and cherry tomatoes. A light, fresh Italian dish that''s naturally gluten-free and perfect for summer.',
    15,
    'Easy',
    'Italian',
    ARRAY['Vegetarian', 'Gluten-Free', 'Quick & Easy']::text[],
    '[
        {"name": "Large zucchini", "amount": "4", "unit": "medium"},
        {"name": "Fresh basil", "amount": "2", "unit": "cups"},
        {"name": "Pine nuts", "amount": "1/4", "unit": "cup"},
        {"name": "Parmesan cheese", "amount": "1/2", "unit": "cup"},
        {"name": "Garlic", "amount": "2", "unit": "cloves"},
        {"name": "Cherry tomatoes", "amount": "1", "unit": "pint"},
        {"name": "Olive oil", "amount": "1/3", "unit": "cup"},
        {"name": "Lemon juice", "amount": "1", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Spiralize zucchini into noodles, set aside",
        "Make pesto: blend basil, pine nuts, garlic, Parmesan, olive oil",
        "Halve cherry tomatoes",
        "Heat large pan, add zucchini noodles for 2-3 minutes",
        "Toss with pesto and cherry tomatoes",
        "Finish with lemon juice and extra Parmesan"
    ]'::jsonb,
    '{"calories": 320, "protein": 12, "carbs": 18, "fat": 24}'::jsonb
),
(
    'Gluten-Free Chicken Piccata',
    'Tender chicken breasts in a tangy lemon-caper sauce, served over gluten-free pasta. Classic Italian flavors with a bright, citrusy finish that''s completely gluten-free.',
    25,
    'Medium',
    'Italian',
    ARRAY['High-Protein', 'Gluten-Free']::text[],
    '[
        {"name": "Chicken breasts", "amount": "2", "unit": "large"},
        {"name": "Gluten-free flour", "amount": "1/2", "unit": "cup"},
        {"name": "White wine", "amount": "1/2", "unit": "cup"},
        {"name": "Chicken broth", "amount": "1/2", "unit": "cup"},
        {"name": "Capers", "amount": "3", "unit": "tbsp"},
        {"name": "Lemon", "amount": "2", "unit": "large"},
        {"name": "Butter", "amount": "4", "unit": "tbsp"},
        {"name": "Gluten-free pasta", "amount": "8", "unit": "oz"}
    ]'::jsonb,
    '[
        "Pound chicken to 1/2 inch thickness, season with salt and pepper",
        "Dredge in gluten-free flour, shaking off excess",
        "Heat butter in large skillet, cook chicken 3-4 minutes per side",
        "Remove chicken, add wine and broth to pan",
        "Simmer until reduced by half, add capers and lemon juice",
        "Return chicken to pan, cook 2 minutes",
        "Swirl in remaining butter, serve over pasta"
    ]'::jsonb,
    '{"calories": 460, "protein": 42, "carbs": 28, "fat": 20}'::jsonb
);
