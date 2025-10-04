-- Add user data tables for favorites, ratings, and usage tracking
-- Migration for MealAdvisor iOS app

-- =================================================================
-- 1. FAVORITES TABLE
-- =================================================================
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure user can't favorite same meal twice
    UNIQUE(user_id, meal_id)
);

-- Create indexes for better query performance
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_favorites_meal_id ON favorites(meal_id);
CREATE INDEX idx_favorites_created_at ON favorites(created_at DESC);

-- Enable Row Level Security
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- RLS Policies for favorites
CREATE POLICY "Users can view own favorites" ON favorites
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites" ON favorites
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites" ON favorites
    FOR DELETE USING (auth.uid() = user_id);

-- =================================================================
-- 2. MEAL RATINGS TABLE
-- =================================================================
CREATE TABLE meal_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating IN (-1, 1)), -- -1 for dislike, 1 for like
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure user can't rate same meal twice (but can update)
    UNIQUE(user_id, meal_id)
);

-- Create indexes
CREATE INDEX idx_meal_ratings_user_id ON meal_ratings(user_id);
CREATE INDEX idx_meal_ratings_meal_id ON meal_ratings(meal_id);
CREATE INDEX idx_meal_ratings_rating ON meal_ratings(rating);

-- Enable Row Level Security
ALTER TABLE meal_ratings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for meal_ratings
CREATE POLICY "Users can view own ratings" ON meal_ratings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own ratings" ON meal_ratings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own ratings" ON meal_ratings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own ratings" ON meal_ratings
    FOR DELETE USING (auth.uid() = user_id);

-- =================================================================
-- 3. USAGE TRACKING TABLE (for suggestion counter)
-- =================================================================
CREATE TABLE usage_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    device_id TEXT, -- For non-authenticated users
    tracking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    suggestion_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure one record per user/device per day
    UNIQUE(user_id, tracking_date),
    UNIQUE(device_id, tracking_date)
);

-- Create indexes
CREATE INDEX idx_usage_tracking_user_id ON usage_tracking(user_id);
CREATE INDEX idx_usage_tracking_device_id ON usage_tracking(device_id);
CREATE INDEX idx_usage_tracking_date ON usage_tracking(tracking_date DESC);

-- Enable Row Level Security
ALTER TABLE usage_tracking ENABLE ROW LEVEL SECURITY;

-- RLS Policies for usage_tracking
CREATE POLICY "Users can view own usage" ON usage_tracking
    FOR SELECT USING (auth.uid() = user_id OR device_id IS NOT NULL);

CREATE POLICY "Users can insert own usage" ON usage_tracking
    FOR INSERT WITH CHECK (auth.uid() = user_id OR device_id IS NOT NULL);

CREATE POLICY "Users can update own usage" ON usage_tracking
    FOR UPDATE USING (auth.uid() = user_id OR device_id IS NOT NULL);

-- =================================================================
-- 4. UPDATE USER_PREFERENCES TABLE
-- =================================================================
-- Add foreign key to auth.users if it doesn't exist
ALTER TABLE user_preferences 
    ADD CONSTRAINT user_preferences_user_id_fkey 
    FOREIGN KEY (user_id) 
    REFERENCES auth.users(id) 
    ON DELETE CASCADE;

-- Add meal ratings JSONB column for storing liked/disliked meals
ALTER TABLE user_preferences 
    ADD COLUMN IF NOT EXISTS meal_ratings JSONB DEFAULT '{}'::jsonb;

-- Add serving size preference
ALTER TABLE user_preferences 
    ADD COLUMN IF NOT EXISTS serving_size INTEGER DEFAULT 2;

-- =================================================================
-- 5. CREATE HELPER FUNCTIONS
-- =================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_favorites_updated_at BEFORE UPDATE ON favorites
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meal_ratings_updated_at BEFORE UPDATE ON meal_ratings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_usage_tracking_updated_at BEFORE UPDATE ON usage_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =================================================================
-- 6. CREATE VIEWS FOR ANALYTICS
-- =================================================================

-- View for user favorite statistics
CREATE OR REPLACE VIEW user_favorite_stats AS
SELECT 
    u.id as user_id,
    u.email,
    COUNT(f.id) as total_favorites,
    MAX(f.created_at) as last_favorited_at
FROM auth.users u
LEFT JOIN favorites f ON u.id = f.user_id
GROUP BY u.id, u.email;

-- View for meal popularity
CREATE OR REPLACE VIEW meal_popularity AS
SELECT 
    m.id as meal_id,
    m.title,
    m.cuisine,
    COUNT(DISTINCT f.user_id) as favorite_count,
    COUNT(CASE WHEN mr.rating = 1 THEN 1 END) as like_count,
    COUNT(CASE WHEN mr.rating = -1 THEN 1 END) as dislike_count,
    COALESCE(AVG(CASE WHEN mr.rating = 1 THEN 1.0 WHEN mr.rating = -1 THEN 0.0 END), 0.5) as approval_rate
FROM meals m
LEFT JOIN favorites f ON m.id = f.meal_id
LEFT JOIN meal_ratings mr ON m.id = mr.meal_id
GROUP BY m.id, m.title, m.cuisine;

-- =================================================================
-- MIGRATION COMPLETE
-- =================================================================

