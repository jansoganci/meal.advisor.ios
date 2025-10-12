-- Run this first to check your database structure
-- Copy output to show me what your meals table looks like

-- Check if meals table exists and show its structure
SELECT 
    column_name, 
    data_type, 
    udt_name,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'meals'
ORDER BY ordinal_position;

-- Check if enum types exist
SELECT typname 
FROM pg_type 
WHERE typname IN ('cuisine_type', 'diet_type');

-- Show existing cuisine values in meals table (if any)
SELECT DISTINCT cuisine 
FROM meals 
LIMIT 20;

-- Show existing diet_tags values in meals table (if any)
SELECT DISTINCT unnest(diet_tags) as diet_tag
FROM meals
LIMIT 20;

