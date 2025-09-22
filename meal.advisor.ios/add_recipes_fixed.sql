-- FIXED RECIPE INSERTION SCRIPT
-- Matches the exact table structure from the migration

-- ITALIAN RECIPES (3)
INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES 
(
    'Chicken Parmesan',
    'Golden-breaded chicken cutlets topped with marinara sauce and melted mozzarella cheese, baked to perfection. A classic Italian-American comfort food favorite that''s crispy on the outside and juicy inside.',
    45,
    'Medium',
    'Italian',
    ARRAY['High-Protein']::text[],
    '[
        {"name": "Chicken breasts", "amount": "2", "unit": "large"},
        {"name": "Panko breadcrumbs", "amount": "1", "unit": "cup"},
        {"name": "Parmesan cheese", "amount": "1/2", "unit": "cup"},
        {"name": "Eggs", "amount": "2", "unit": "large"},
        {"name": "Marinara sauce", "amount": "1.5", "unit": "cups"},
        {"name": "Mozzarella cheese", "amount": "1", "unit": "cup"},
        {"name": "Olive oil", "amount": "1/3", "unit": "cup"}
    ]'::jsonb,
    '[
        "Pound chicken to 1/2 inch thickness and season with salt and pepper",
        "Set up breading station: flour, beaten eggs, and breadcrumb-Parmesan mixture",
        "Bread chicken by dipping in flour, eggs, then breadcrumbs",
        "Pan-fry in olive oil for 2-3 minutes per side until golden",
        "Top with marinara sauce and mozzarella, bake at 425°F for 15 minutes",
        "Broil for 1-2 minutes until cheese is bubbly and golden"
    ]'::jsonb,
    '{"calories": 520, "protein": 45, "carbs": 22, "fat": 28}'::jsonb
),
(
    'Margherita Pizza',
    'Classic Neapolitan pizza featuring fresh mozzarella, San Marzano tomato sauce, and fresh basil on a crispy, chewy crust. Simple ingredients that showcase the essence of authentic Italian flavors.',
    25,
    'Medium',
    'Italian',
    ARRAY['Vegetarian']::text[],
    '[
        {"name": "Pizza dough", "amount": "1", "unit": "ball"},
        {"name": "San Marzano tomato sauce", "amount": "1/2", "unit": "cup"},
        {"name": "Fresh mozzarella", "amount": "4", "unit": "oz"},
        {"name": "Olive oil", "amount": "2", "unit": "tbsp"},
        {"name": "Parmesan cheese", "amount": "1/4", "unit": "cup"},
        {"name": "Fresh basil leaves", "amount": "8", "unit": "leaves"}
    ]'::jsonb,
    '[
        "Preheat oven to 500°F and dust baking sheet with cornmeal",
        "Stretch pizza dough into large oval on prepared sheet",
        "Brush with olive oil, then spread tomato sauce leaving 1-inch border",
        "Top with torn mozzarella and Parmesan cheese",
        "Bake for 10-12 minutes until crust is golden and cheese bubbles",
        "Remove from oven, top with fresh basil and drizzle with olive oil"
    ]'::jsonb,
    '{"calories": 350, "protein": 16, "carbs": 42, "fat": 14}'::jsonb
),
(
    'Fettuccine Alfredo',
    'Rich, creamy pasta dish with silky butter and Parmesan sauce coating tender fettuccine noodles. A luxurious comfort food that''s surprisingly simple to make at home.',
    20,
    'Easy',
    'Italian',
    ARRAY['Vegetarian', 'Quick & Easy']::text[],
    '[
        {"name": "Fettuccine pasta", "amount": "1", "unit": "lb"},
        {"name": "Butter", "amount": "6", "unit": "tbsp"},
        {"name": "Heavy cream", "amount": "1.5", "unit": "cups"},
        {"name": "Parmesan cheese", "amount": "1.25", "unit": "cups"},
        {"name": "Garlic", "amount": "2", "unit": "cloves"}
    ]'::jsonb,
    '[
        "Cook fettuccine according to package directions until al dente, reserve pasta water",
        "In large skillet, melt butter over medium heat, add minced garlic for 1-2 minutes",
        "Add heavy cream and bring to gentle simmer for 5-8 minutes until thickened",
        "Remove from heat, whisk in Parmesan cheese until smooth and creamy",
        "Add cooked pasta to sauce, toss until well coated",
        "Season with salt and pepper, add pasta water if needed for consistency"
    ]'::jsonb,
    '{"calories": 480, "protein": 18, "carbs": 52, "fat": 24}'::jsonb
);

-- ASIAN RECIPES (3)
INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES 
(
    'Chicken Fried Rice',
    'Better-than-takeout fried rice with tender chicken, scrambled eggs, and colorful vegetables all stir-fried with day-old rice and savory soy sauce. Perfect for using leftover rice and chicken.',
    20,
    'Easy',
    'Asian',
    ARRAY['High-Protein', 'Quick & Easy']::text[],
    '[
        {"name": "Cooked rice", "amount": "3", "unit": "cups"},
        {"name": "Chicken breast", "amount": "1/2", "unit": "lb"},
        {"name": "Eggs", "amount": "2", "unit": "beaten"},
        {"name": "Frozen peas and carrots", "amount": "1.5", "unit": "cups"},
        {"name": "Green onions", "amount": "3", "unit": "chopped"},
        {"name": "Garlic", "amount": "3", "unit": "cloves"},
        {"name": "Soy sauce", "amount": "3", "unit": "tbsp"},
        {"name": "Sesame oil", "amount": "2", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Heat oil in large skillet or wok over medium-high heat",
        "Cook diced chicken until no longer pink, about 6-7 minutes, set aside",
        "Scramble eggs in same pan, then add frozen vegetables and cook 4 minutes",
        "Add garlic and cook 1 minute until fragrant",
        "Add rice, chicken, soy sauce, and green onions, stir-fry until heated through",
        "Drizzle with sesame oil before serving"
    ]'::jsonb,
    '{"calories": 385, "protein": 28, "carbs": 45, "fat": 12}'::jsonb
),
(
    'Pad Thai',
    'Authentic Thai stir-fried rice noodles with sweet and tangy tamarind sauce, tender chicken, bean sprouts, and peanuts. A perfect balance of sweet, sour, and savory flavors.',
    35,
    'Medium',
    'Asian',
    ARRAY['High-Protein']::text[],
    '[
        {"name": "Rice noodles", "amount": "8", "unit": "oz"},
        {"name": "Chicken breast", "amount": "8", "unit": "oz"},
        {"name": "Fish sauce", "amount": "3", "unit": "tbsp"},
        {"name": "Tamarind paste", "amount": "3", "unit": "tbsp"},
        {"name": "Palm sugar", "amount": "3", "unit": "tbsp"},
        {"name": "Eggs", "amount": "2", "unit": "pieces"},
        {"name": "Bean sprouts", "amount": "2", "unit": "cups"},
        {"name": "Roasted peanuts", "amount": "1/4", "unit": "cup"},
        {"name": "Vegetable oil", "amount": "3", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Soak rice noodles in warm water for 1 hour until soft",
        "Make sauce by combining fish sauce, tamarind paste, palm sugar, and water",
        "Heat oil in wok, stir-fry chicken until cooked through, set aside",
        "Scramble eggs in same wok, add drained noodles and sauce",
        "Add chicken back to wok with bean sprouts, toss until noodles are tender",
        "Serve garnished with chopped peanuts and lime wedges"
    ]'::jsonb,
    '{"calories": 420, "protein": 32, "carbs": 48, "fat": 14}'::jsonb
),
(
    'Teriyaki Salmon',
    'Flaky baked salmon glazed with sweet and savory homemade teriyaki sauce, topped with sesame seeds and green onions. A healthy, restaurant-quality dish that''s easy to make at home.',
    30,
    'Easy',
    'Asian',
    ARRAY['High-Protein', 'Gluten-Free']::text[],
    '[
        {"name": "Salmon fillets", "amount": "2", "unit": "lbs"},
        {"name": "Soy sauce", "amount": "1/2", "unit": "cup"},
        {"name": "Brown sugar", "amount": "2", "unit": "tbsp"},
        {"name": "Rice vinegar", "amount": "1", "unit": "tbsp"},
        {"name": "Garlic", "amount": "2", "unit": "cloves"},
        {"name": "Fresh ginger", "amount": "1", "unit": "tsp"},
        {"name": "Sesame seeds", "amount": "1", "unit": "tbsp"},
        {"name": "Green onions", "amount": "2", "unit": "chopped"}
    ]'::jsonb,
    '[
        "Preheat oven to 400°F and line baking sheet with parchment",
        "Whisk together soy sauce, brown sugar, vinegar, garlic, and ginger for sauce",
        "Marinate salmon in half the sauce for 20 minutes",
        "Place salmon on prepared baking sheet, bake for 12-15 minutes until flaky",
        "Simmer remaining sauce in small pan until thickened, about 5 minutes",
        "Brush cooked salmon with thickened sauce, garnish with sesame seeds and green onions"
    ]'::jsonb,
    '{"calories": 340, "protein": 35, "carbs": 8, "fat": 18}'::jsonb
);

-- AMERICAN RECIPES (4)
INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES 
(
    'Grilled Cheese & Tomato Soup',
    'Classic comfort food duo featuring golden, crispy grilled cheese sandwich made with sharp cheddar and creamy, rich tomato soup. Perfect for cold days and nostalgic dining.',
    35,
    'Easy',
    'American',
    ARRAY['Vegetarian', 'Quick & Easy']::text[],
    '[
        {"name": "Bread slices", "amount": "4", "unit": "slices"},
        {"name": "Sharp cheddar cheese", "amount": "4", "unit": "slices"},
        {"name": "Butter", "amount": "2", "unit": "tbsp"},
        {"name": "Crushed tomatoes", "amount": "28", "unit": "oz can"},
        {"name": "Heavy cream", "amount": "1/2", "unit": "cup"},
        {"name": "Onion", "amount": "1", "unit": "medium"},
        {"name": "Garlic", "amount": "2", "unit": "cloves"},
        {"name": "Dried basil", "amount": "1", "unit": "tsp"}
    ]'::jsonb,
    '[
        "Sauté diced onion in butter until soft, add garlic for 1 minute",
        "Add crushed tomatoes, basil, salt and pepper, simmer 10 minutes",
        "Blend soup until smooth, stir in heavy cream",
        "Butter bread slices, place cheese between unbuttered sides",
        "Cook sandwiches in skillet over medium heat 2-3 minutes per side until golden",
        "Serve hot grilled cheese with warm tomato soup"
    ]'::jsonb,
    '{"calories": 425, "protein": 16, "carbs": 38, "fat": 24}'::jsonb
),
(
    'BBQ Pulled Pork',
    'Tender, slow-cooked pork shoulder that shreds easily and is smothered in tangy BBQ sauce. Perfect for sandwiches, wraps, or serving over rice with minimal prep work.',
    15,
    'Easy',
    'American',
    ARRAY['High-Protein', 'Gluten-Free']::text[],
    '[
        {"name": "Pork shoulder", "amount": "2", "unit": "lbs"},
        {"name": "BBQ sauce", "amount": "1/2", "unit": "cup"},
        {"name": "Smoked paprika", "amount": "2", "unit": "tsp"},
        {"name": "Garlic powder", "amount": "2", "unit": "tsp"},
        {"name": "Kosher salt", "amount": "1", "unit": "tsp"},
        {"name": "Black pepper", "amount": "1/2", "unit": "tsp"},
        {"name": "Apple cider vinegar", "amount": "2", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Season pork shoulder with paprika, garlic powder, salt, and pepper",
        "Place in slow cooker, pour BBQ sauce and vinegar over top",
        "Cook on low 8-10 hours or high 4-6 hours until fork-tender",
        "Remove pork, shred with two forks, discard excess liquid",
        "Mix shredded pork with 3/4 cup cooking liquid and extra BBQ sauce",
        "Cook on high 1 more hour, serve on buns or over rice"
    ]'::jsonb,
    '{"calories": 380, "protein": 42, "carbs": 8, "fat": 18}'::jsonb
),
(
    'Baked Mac and Cheese',
    'Ultimate creamy, cheesy macaroni and cheese made with a rich cheese sauce and topped with golden, crispy breadcrumbs. More indulgent than stovetop versions with irresistible texture contrast.',
    35,
    'Medium',
    'American',
    ARRAY['Vegetarian']::text[],
    '[
        {"name": "Elbow macaroni", "amount": "1", "unit": "lb"},
        {"name": "Sharp cheddar", "amount": "4", "unit": "cups"},
        {"name": "Butter", "amount": "6", "unit": "tbsp"},
        {"name": "Flour", "amount": "1/3", "unit": "cup"},
        {"name": "Whole milk", "amount": "3", "unit": "cups"},
        {"name": "Heavy cream", "amount": "1", "unit": "cup"},
        {"name": "Panko breadcrumbs", "amount": "1.5", "unit": "cups"},
        {"name": "Parmesan", "amount": "1/2", "unit": "cup"}
    ]'::jsonb,
    '[
        "Cook macaroni 1 minute shy of al dente, drain and set aside",
        "Make roux by melting butter, whisking in flour, cook 1 minute",
        "Gradually whisk in milk and cream, cook until thickened like gravy",
        "Remove from heat, stir in 3 cups cheddar until melted and smooth",
        "Mix cheese sauce with cooked pasta, transfer to greased 9x13 baking dish",
        "Top with remaining cheddar, panko-Parmesan mixture, bake at 350°F for 30 minutes"
    ]'::jsonb,
    '{"calories": 510, "protein": 22, "carbs": 48, "fat": 26}'::jsonb
),
(
    'Chicken Caesar Salad',
    'Crisp romaine lettuce topped with juicy grilled chicken, creamy Caesar dressing, crunchy croutons, and Parmesan cheese. A satisfying, restaurant-quality salad perfect for lunch or light dinner.',
    25,
    'Easy',
    'American',
    ARRAY['High-Protein', 'Low-Carb']::text[],
    '[
        {"name": "Chicken breasts", "amount": "2", "unit": "pieces"},
        {"name": "Romaine lettuce", "amount": "2", "unit": "heads"},
        {"name": "Mayonnaise", "amount": "1/2", "unit": "cup"},
        {"name": "Parmesan", "amount": "1/4", "unit": "cup"},
        {"name": "Lemon juice", "amount": "2", "unit": "tbsp"},
        {"name": "Worcestershire sauce", "amount": "1", "unit": "tsp"},
        {"name": "Croutons", "amount": "2", "unit": "cups"},
        {"name": "Garlic", "amount": "2", "unit": "cloves"}
    ]'::jsonb,
    '[
        "Season chicken with salt and pepper, grill 6-7 minutes per side until cooked through",
        "Let chicken rest 5 minutes, then slice into strips",
        "Make dressing by whisking mayo, Parmesan, lemon juice, Worcestershire, and garlic",
        "Toss chopped romaine with dressing until well coated",
        "Top salad with sliced chicken and croutons",
        "Serve immediately with extra Parmesan if desired"
    ]'::jsonb,
    '{"calories": 395, "protein": 35, "carbs": 18, "fat": 22}'::jsonb
);

-- MEDITERRANEAN RECIPES (2)
INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES 
(
    'Mediterranean Hummus Bowl',
    'Nourishing bowl with creamy homemade hummus, fluffy quinoa, fresh vegetables, and Mediterranean flavors. A healthy, plant-based meal that''s filling and packed with protein and fiber.',
    20,
    'Easy',
    'Mediterranean',
    ARRAY['Vegetarian', 'Gluten-Free', 'High-Protein']::text[],
    '[
        {"name": "Chickpeas", "amount": "15", "unit": "oz can"},
        {"name": "Tahini", "amount": "1/4", "unit": "cup"},
        {"name": "Lemon juice", "amount": "3", "unit": "tbsp"},
        {"name": "Cooked quinoa", "amount": "1", "unit": "cup"},
        {"name": "Cherry tomatoes", "amount": "1", "unit": "cup"},
        {"name": "English cucumber", "amount": "1/2", "unit": "cucumber"},
        {"name": "Kalamata olives", "amount": "1/4", "unit": "cup"},
        {"name": "Olive oil", "amount": "2", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Make hummus by blending chickpeas, tahini, lemon juice, and 2-3 ice cubes until smooth",
        "Cook quinoa according to package directions and let cool",
        "Prepare vegetables: dice cucumber, halve cherry tomatoes",
        "Spread hummus in serving bowls as base",
        "Arrange quinoa, tomatoes, cucumber, and olives over hummus",
        "Drizzle with olive oil and serve with pita bread"
    ]'::jsonb,
    '{"calories": 324, "protein": 14, "carbs": 44, "fat": 12}'::jsonb
),
(
    'Grilled Chicken Souvlaki',
    'Tender, marinated chicken skewers grilled to perfection with Mediterranean herbs and served with cooling tzatziki sauce. Transport yourself to the Greek islands with every bite.',
    45,
    'Medium',
    'Mediterranean',
    ARRAY['High-Protein', 'Gluten-Free']::text[],
    '[
        {"name": "Chicken thighs", "amount": "2", "unit": "lbs"},
        {"name": "Olive oil", "amount": "1/3", "unit": "cup"},
        {"name": "Lemon juice", "amount": "2", "unit": "tbsp"},
        {"name": "Garlic", "amount": "3", "unit": "cloves"},
        {"name": "Dried oregano", "amount": "2", "unit": "tsp"},
        {"name": "Greek yogurt", "amount": "1/2", "unit": "cup"},
        {"name": "Cucumber", "amount": "1/2", "unit": "cucumber"},
        {"name": "Kosher salt", "amount": "1", "unit": "tsp"}
    ]'::jsonb,
    '[
        "Marinate chicken in olive oil, lemon juice, garlic, oregano, and salt for 30 minutes",
        "Make tzatziki by combining yogurt, grated cucumber, and garlic",
        "Thread marinated chicken onto metal skewers",
        "Preheat grill to medium-high heat",
        "Grill skewers 3-4 minutes per side until cooked through and slightly charred",
        "Serve immediately with tzatziki sauce and pita bread"
    ]'::jsonb,
    '{"calories": 310, "protein": 28, "carbs": 6, "fat": 19}'::jsonb
);

-- MEXICAN RECIPES (3)
INSERT INTO meals (title, description, prep_time, difficulty, cuisine, diet_tags, ingredients, instructions, nutrition_info) VALUES 
(
    'Chicken Quesadilla',
    'Crispy, golden tortillas filled with seasoned shredded chicken and melted cheese, cooked until perfectly crispy outside and gooey inside. Perfect for quick meals or appetizers.',
    15,
    'Easy',
    'Mexican',
    ARRAY['High-Protein', 'Quick & Easy']::text[],
    '[
        {"name": "Flour tortillas", "amount": "4", "unit": "large"},
        {"name": "Cooked chicken", "amount": "2", "unit": "cups"},
        {"name": "Mexican cheese blend", "amount": "1.5", "unit": "cups"},
        {"name": "Bell peppers", "amount": "1/2", "unit": "cup"},
        {"name": "Onions", "amount": "1/2", "unit": "cup"},
        {"name": "Taco seasoning", "amount": "2", "unit": "tsp"},
        {"name": "Vegetable oil", "amount": "2", "unit": "tbsp"}
    ]'::jsonb,
    '[
        "Season shredded chicken with taco seasoning",
        "Heat 1 tsp oil in large skillet over medium heat",
        "Place tortilla in pan, add chicken, cheese, peppers, and onions to half",
        "Fold tortilla over filling and cook 2-3 minutes per side until golden",
        "Repeat with remaining tortillas and filling",
        "Cut into wedges and serve with salsa and sour cream"
    ]'::jsonb,
    '{"calories": 445, "protein": 28, "carbs": 32, "fat": 22}'::jsonb
),
(
    'Chicken Burrito Bowl',
    'Chipotle-style bowl with seasoned ground beef, cilantro lime rice, black beans, corn, and fresh toppings. Customizable and satisfying meal that''s perfect for meal prep.',
    35,
    'Easy',
    'Mexican',
    ARRAY['High-Protein', 'Gluten-Free']::text[],
    '[
        {"name": "Ground beef", "amount": "1", "unit": "lb"},
        {"name": "Cooked rice", "amount": "2", "unit": "cups"},
        {"name": "Black beans", "amount": "1", "unit": "can"},
        {"name": "Corn kernels", "amount": "1", "unit": "cup"},
        {"name": "Taco seasoning", "amount": "1", "unit": "tbsp"},
        {"name": "Lime juice", "amount": "1/4", "unit": "cup"},
        {"name": "Cilantro", "amount": "1/4", "unit": "cup"},
        {"name": "Shredded cheese", "amount": "1", "unit": "cup"}
    ]'::jsonb,
    '[
        "Cook ground beef in large skillet, drain fat, add taco seasoning with water",
        "Mix cooked rice with lime juice and chopped cilantro",
        "Heat black beans and corn in separate pan until warmed through",
        "Assemble bowls with rice as base",
        "Top with seasoned beef, beans, corn, and cheese",
        "Add desired toppings like avocado, salsa, and sour cream"
    ]'::jsonb,
    '{"calories": 520, "protein": 32, "carbs": 48, "fat": 22}'::jsonb
),
(
    'Chicken Enchiladas',
    'Soft corn tortillas filled with seasoned shredded chicken and cheese, smothered in rich enchilada sauce and baked until bubbly. A crowd-pleasing Mexican comfort food classic.',
    50,
    'Medium',
    'Mexican',
    ARRAY['High-Protein']::text[],
    '[
        {"name": "Corn tortillas", "amount": "8", "unit": "tortillas"},
        {"name": "Cooked chicken", "amount": "3", "unit": "cups"},
        {"name": "Enchilada sauce", "amount": "2", "unit": "cups"},
        {"name": "Mexican cheese", "amount": "2", "unit": "cups"},
        {"name": "Onion", "amount": "1", "unit": "medium"},
        {"name": "Cilantro", "amount": "1/4", "unit": "cup"},
        {"name": "Vegetable oil", "amount": "2", "unit": "tbsp"},
        {"name": "Cumin", "amount": "1", "unit": "tsp"}
    ]'::jsonb,
    '[
        "Preheat oven to 350°F and grease 9x13 baking dish",
        "Sauté onion until soft, mix with shredded chicken, cilantro, and cumin",
        "Warm tortillas to make them pliable for rolling",
        "Fill each tortilla with chicken mixture and 2 tbsp cheese, roll and place seam-down in dish",
        "Pour enchilada sauce over top, sprinkle with remaining cheese",
        "Bake covered 20-25 minutes until heated through and cheese is melted"
    ]'::jsonb,
    '{"calories": 465, "protein": 35, "carbs": 28, "fat": 24}'::jsonb
);
