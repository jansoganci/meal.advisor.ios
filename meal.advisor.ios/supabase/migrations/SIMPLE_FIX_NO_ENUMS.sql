-- SIMPLE FIX - Use this if your meals table uses TEXT instead of enums
-- This will work even if cuisine_type and diet_type enums don't exist

-- This migration is OPTIONAL and safe to run
-- If your meals table uses TEXT fields, no database changes are needed!
-- The app will automatically work with the new cuisine and diet values.

-- You only need to run this IF:
-- 1. You get enum constraint errors when trying to insert new cuisines
-- 2. You want to enforce specific values at the database level

-- For now, just rebuild the iOS app - it should work immediately!
SELECT 'No database changes needed - app will handle new values' as status;

