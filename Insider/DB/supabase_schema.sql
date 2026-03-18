-- Supabase Database Schema
-- Run this SQL in your Supabase SQL Editor to create all necessary tables

-- ================================================
-- 1. NEWS CARDS TABLE
-- ================================================

CREATE TABLE IF NOT EXISTS news_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    article_url TEXT,
    source TEXT NOT NULL,
    user_name TEXT NOT NULL,
    profile_color TEXT DEFAULT '#007AFF',
    tags TEXT[] DEFAULT '{}',
    code_snippet TEXT,
    snippet_language TEXT,
    published_date TIMESTAMPTZ,
    
    -- Interaction counters
    likes_count INTEGER DEFAULT 0,
    dislikes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    discussions_count INTEGER DEFAULT 0,
    bookmarks_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_news_cards_created_at ON news_cards(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_cards_tags ON news_cards USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_news_cards_source ON news_cards(source);
CREATE INDEX IF NOT EXISTS idx_news_cards_title ON news_cards USING GIN(to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS idx_news_cards_description ON news_cards USING GIN(to_tsvector('english', description));

-- ================================================
-- 2. USER INTERACTIONS TABLE
-- ================================================

CREATE TABLE IF NOT EXISTS user_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL, -- Device ID or authenticated user ID
    news_card_id UUID NOT NULL REFERENCES news_cards(id) ON DELETE CASCADE,
    interaction_type TEXT NOT NULL CHECK (interaction_type IN ('like', 'dislike', 'bookmark', 'comment', 'discussion')),
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one interaction per user per card per type
    UNIQUE(user_id, news_card_id, interaction_type)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_interactions_user_id ON user_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_news_card_id ON user_interactions(news_card_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_type ON user_interactions(interaction_type);
CREATE INDEX IF NOT EXISTS idx_user_interactions_active ON user_interactions(is_active) WHERE is_active = TRUE;

-- ================================================
-- 3. DISCUSSIONS TABLE
-- ================================================

CREATE TABLE IF NOT EXISTS discussions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_card_id UUID NOT NULL REFERENCES news_cards(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_profile_color TEXT DEFAULT '#007AFF',
    question TEXT NOT NULL,
    participants_count INTEGER DEFAULT 1,
    messages_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_discussions_news_card_id ON discussions(news_card_id);
CREATE INDEX IF NOT EXISTS idx_discussions_user_id ON discussions(user_id);
CREATE INDEX IF NOT EXISTS idx_discussions_created_at ON discussions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_discussions_active ON discussions(is_active) WHERE is_active = TRUE;

-- ================================================
-- 4. COMMENTS TABLE
-- ================================================

CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    news_card_id UUID NOT NULL REFERENCES news_cards(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_profile_color TEXT DEFAULT '#007AFF',
    text TEXT NOT NULL,
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    level INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    is_edited BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_comments_news_card_id ON comments(news_card_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at ASC);

-- ================================================
-- 5. TRIGGERS FOR UPDATED_AT
-- ================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables
DROP TRIGGER IF EXISTS update_news_cards_updated_at ON news_cards;
CREATE TRIGGER update_news_cards_updated_at
    BEFORE UPDATE ON news_cards
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_interactions_updated_at ON user_interactions;
CREATE TRIGGER update_user_interactions_updated_at
    BEFORE UPDATE ON user_interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_discussions_updated_at ON discussions;
CREATE TRIGGER update_discussions_updated_at
    BEFORE UPDATE ON discussions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- 6. FUNCTIONS TO UPDATE COUNTERS
-- ================================================

-- Function to update news card counters based on user interactions
CREATE OR REPLACE FUNCTION update_news_card_counters()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Update the counter based on interaction type
        IF NEW.interaction_type = 'like' THEN
            UPDATE news_cards
            SET likes_count = (
                SELECT COUNT(*)
                FROM user_interactions
                WHERE news_card_id = NEW.news_card_id
                AND interaction_type = 'like'
                AND is_active = TRUE
            )
            WHERE id = NEW.news_card_id;
        ELSIF NEW.interaction_type = 'dislike' THEN
            UPDATE news_cards
            SET dislikes_count = (
                SELECT COUNT(*)
                FROM user_interactions
                WHERE news_card_id = NEW.news_card_id
                AND interaction_type = 'dislike'
                AND is_active = TRUE
            )
            WHERE id = NEW.news_card_id;
        ELSIF NEW.interaction_type = 'bookmark' THEN
            UPDATE news_cards
            SET bookmarks_count = (
                SELECT COUNT(*)
                FROM user_interactions
                WHERE news_card_id = NEW.news_card_id
                AND interaction_type = 'bookmark'
                AND is_active = TRUE
            )
            WHERE id = NEW.news_card_id;
        END IF;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        -- Update the counter when interaction is deleted
        IF OLD.interaction_type = 'like' THEN
            UPDATE news_cards
            SET likes_count = GREATEST(0, likes_count - 1)
            WHERE id = OLD.news_card_id;
        ELSIF OLD.interaction_type = 'dislike' THEN
            UPDATE news_cards
            SET dislikes_count = GREATEST(0, dislikes_count - 1)
            WHERE id = OLD.news_card_id;
        ELSIF OLD.interaction_type = 'bookmark' THEN
            UPDATE news_cards
            SET bookmarks_count = GREATEST(0, bookmarks_count - 1)
            WHERE id = OLD.news_card_id;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to user_interactions
DROP TRIGGER IF EXISTS update_counters_on_interaction ON user_interactions;
CREATE TRIGGER update_counters_on_interaction
    AFTER INSERT OR UPDATE OR DELETE ON user_interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_news_card_counters();

-- Function to update comment count
CREATE OR REPLACE FUNCTION update_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE news_cards
        SET comments_count = comments_count + 1
        WHERE id = NEW.news_card_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE news_cards
        SET comments_count = GREATEST(0, comments_count - 1)
        WHERE id = OLD.news_card_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to comments
DROP TRIGGER IF EXISTS update_comment_count_trigger ON comments;
CREATE TRIGGER update_comment_count_trigger
    AFTER INSERT OR DELETE ON comments
    FOR EACH ROW
    EXECUTE FUNCTION update_comment_count();

-- Function to update discussion count
CREATE OR REPLACE FUNCTION update_discussion_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE news_cards
        SET discussions_count = discussions_count + 1
        WHERE id = NEW.news_card_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE news_cards
        SET discussions_count = GREATEST(0, discussions_count - 1)
        WHERE id = OLD.news_card_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to discussions
DROP TRIGGER IF EXISTS update_discussion_count_trigger ON discussions;
CREATE TRIGGER update_discussion_count_trigger
    AFTER INSERT OR DELETE ON discussions
    FOR EACH ROW
    EXECUTE FUNCTION update_discussion_count();

-- ================================================
-- 7. ROW LEVEL SECURITY (RLS) - OPTIONAL
-- ================================================

-- Enable RLS on all tables (uncomment if you want to use authentication)
-- ALTER TABLE news_cards ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE user_interactions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Example RLS Policies (uncomment and modify as needed)
-- Allow anyone to read news cards
-- CREATE POLICY "News cards are viewable by everyone"
--     ON news_cards FOR SELECT
--     USING (true);

-- Allow authenticated users to insert news cards
-- CREATE POLICY "Authenticated users can insert news cards"
--     ON news_cards FOR INSERT
--     WITH CHECK (auth.role() = 'authenticated');

-- ================================================
-- 8. SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ================================================

-- Uncomment to insert sample data
/*
INSERT INTO news_cards (title, description, image_url, article_url, source, user_name, tags, likes_count, comments_count)
VALUES
(
    'Sample Tech News Article',
    'This is a sample description for testing the database setup.',
    'https://via.placeholder.com/400x200',
    'https://example.com/article',
    'TechCrunch',
    'Tech Insider',
    ARRAY['technology', 'ai', 'news'],
    42,
    5
);
*/

-- ================================================
-- SETUP COMPLETE!
-- ================================================

-- To verify tables were created, run:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
