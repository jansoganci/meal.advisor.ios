-- Add new cuisine types and diet types to match Swift enums
-- Date: October 11, 2025

-- Check if enum types exist, if so add new values
DO $$ 
BEGIN
    -- Only run if cuisine_type enum exists
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'cuisine_type') THEN
        -- Add new cuisine types to existing enum
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'Turkish' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'cuisine_type')) THEN
            ALTER TYPE cuisine_type ADD VALUE 'Turkish';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'Chinese' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'cuisine_type')) THEN
            ALTER TYPE cuisine_type ADD VALUE 'Chinese';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'Japanese' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'cuisine_type')) THEN
            ALTER TYPE cuisine_type ADD VALUE 'Japanese';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'French' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'cuisine_type')) THEN
            ALTER TYPE cuisine_type ADD VALUE 'French';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'Thai' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'cuisine_type')) THEN
            ALTER TYPE cuisine_type ADD VALUE 'Thai';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'Indian' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'cuisine_type')) THEN
            ALTER TYPE cuisine_type ADD VALUE 'Indian';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'Spanish' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'cuisine_type')) THEN
            ALTER TYPE cuisine_type ADD VALUE 'Spanish';
        END IF;
    ELSE
        RAISE NOTICE 'cuisine_type enum does not exist - skipping cuisine updates';
    END IF;

    -- Only run if diet_type enum exists
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'diet_type') THEN
        -- Add "No Pork" diet type
        IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'No Pork' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'diet_type')) THEN
            ALTER TYPE diet_type ADD VALUE 'No Pork';
        END IF;
    ELSE
        RAISE NOTICE 'diet_type enum does not exist - skipping diet updates';
    END IF;
END $$;

-- If meals table uses TEXT instead of enums, no migration needed
-- The app will work with any text values