-- ============================================
-- Up Sword Game - Complete Database Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PROFILES TABLE (사용자 프로필)
-- ============================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname VARCHAR(25) UNIQUE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    gold BIGINT DEFAULT 10000 CHECK (gold >= 0 AND gold <= 99999999),
    money BIGINT DEFAULT 0 CHECK (money >= 0 AND money <= 999999),
    current_sword_lvl INTEGER DEFAULT 0 CHECK (current_sword_lvl >= 0 AND current_sword_lvl <= 20),
    current_weapon_type VARCHAR(50) DEFAULT 'normal',
    current_weapon_key VARCHAR(50) DEFAULT 'sword_01',
    has_macro BOOLEAN DEFAULT FALSE,
    is_banned BOOLEAN DEFAULT FALSE,
    ban_reason TEXT,
    last_daily_check TIMESTAMP WITH TIME ZONE,
    consecutive_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for profiles
CREATE INDEX idx_profiles_nickname ON profiles(nickname);
CREATE INDEX idx_profiles_gold ON profiles(gold DESC);
CREATE INDEX idx_profiles_current_sword_lvl ON profiles(current_sword_lvl DESC);

-- ============================================
-- 2. SWORD_DATA TABLE (검 데이터)
-- ============================================
CREATE TABLE sword_data (
    id SERIAL PRIMARY KEY,
    level INTEGER UNIQUE NOT NULL CHECK (level >= 0 AND level <= 20),
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default sword data
INSERT INTO sword_data (level, description, image_url) VALUES
(0, '초보자의 검', 'https://via.placeholder.com/300x300?text=Sword+0'),
(1, '+1 강화 검', 'https://via.placeholder.com/300x300?text=Sword+1'),
(2, '+2 강화 검', 'https://via.placeholder.com/300x300?text=Sword+2'),
(3, '+3 강화 검', 'https://via.placeholder.com/300x300?text=Sword+3'),
(4, '+4 강화 검', 'https://via.placeholder.com/300x300?text=Sword+4'),
(5, '+5 강화 검', 'https://via.placeholder.com/300x300?text=Sword+5'),
(6, '+6 강화 검', 'https://via.placeholder.com/300x300?text=Sword+6'),
(7, '+7 강화 검', 'https://via.placeholder.com/300x300?text=Sword+7'),
(8, '+8 강화 검', 'https://via.placeholder.com/300x300?text=Sword+8'),
(9, '+9 강화 검', 'https://via.placeholder.com/300x300?text=Sword+9'),
(10, '+10 강화 검', 'https://via.placeholder.com/300x300?text=Sword+10'),
(11, '+11 강화 검', 'https://via.placeholder.com/300x300?text=Sword+11'),
(12, '+12 강화 검', 'https://via.placeholder.com/300x300?text=Sword+12'),
(13, '+13 강화 검', 'https://via.placeholder.com/300x300?text=Sword+13'),
(14, '+14 강화 검', 'https://via.placeholder.com/300x300?text=Sword+14'),
(15, '+15 강화 검', 'https://via.placeholder.com/300x300?text=Sword+15'),
(16, '+16 강화 검', 'https://via.placeholder.com/300x300?text=Sword+16'),
(17, '+17 강화 검', 'https://via.placeholder.com/300x300?text=Sword+17'),
(18, '+18 강화 검', 'https://via.placeholder.com/300x300?text=Sword+18'),
(19, '+19 강화 검', 'https://via.placeholder.com/300x300?text=Sword+19'),
(20, '+20 전설의 검', 'https://via.placeholder.com/300x300?text=Sword+20');

-- ============================================
-- 3. USER_SWORDS TABLE (사용자 보관 검)
-- ============================================
CREATE TABLE user_swords (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    sword_id VARCHAR(100) NOT NULL,
    sword_level INTEGER NOT NULL CHECK (sword_level >= 0 AND sword_level <= 20),
    weapon_type VARCHAR(50) DEFAULT 'normal',
    weapon_key VARCHAR(50) DEFAULT 'sword_01',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for user_swords
CREATE INDEX idx_user_swords_user_id ON user_swords(user_id);
CREATE INDEX idx_user_swords_sword_level ON user_swords(sword_level DESC);

-- ============================================
-- 4. USER_WEAPON_DISCOVERIES TABLE (무기 발견 기록)
-- ============================================
CREATE TABLE user_weapon_discoveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    weapon_type VARCHAR(50) NOT NULL,
    max_discovered_level INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, weapon_type)
);

-- Index for user_weapon_discoveries
CREATE INDEX idx_user_weapon_discoveries_user_id ON user_weapon_discoveries(user_id);

-- ============================================
-- 5. USER_ITEMS TABLE (사용자 아이템)
-- ============================================
CREATE TABLE user_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    item_id VARCHAR(100) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_type VARCHAR(50),
    quantity INTEGER DEFAULT 1 CHECK (quantity >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for user_items
CREATE INDEX idx_user_items_user_id ON user_items(user_id);
CREATE INDEX idx_user_items_item_id ON user_items(item_id);

-- ============================================
-- 6. REWARD_CODES TABLE (보상 코드)
-- ============================================
CREATE TABLE reward_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    max_uses INTEGER DEFAULT 1,
    current_uses INTEGER DEFAULT 0,
    expires_at TIMESTAMP WITH TIME ZONE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for reward_codes
CREATE INDEX idx_reward_codes_code ON reward_codes(code);
CREATE INDEX idx_reward_codes_active ON reward_codes(active);

-- ============================================
-- 7. ROULETTE_GAMES TABLE (룰렛 게임 기록)
-- ============================================
CREATE TABLE roulette_games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    bet_amount BIGINT NOT NULL,
    bet_type VARCHAR(50) NOT NULL,
    result VARCHAR(50) NOT NULL,
    payout BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for roulette_games
CREATE INDEX idx_roulette_games_user_id ON roulette_games(user_id);
CREATE INDEX idx_roulette_games_created_at ON roulette_games(created_at DESC);

-- ============================================
-- 8. BATTLES TABLE (배틀 기록)
-- ============================================
CREATE TABLE battles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    player2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    winner_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    player1_sword_level INTEGER,
    player2_sword_level INTEGER,
    bet_amount BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for battles
CREATE INDEX idx_battles_player1_id ON battles(player1_id);
CREATE INDEX idx_battles_player2_id ON battles(player2_id);
CREATE INDEX idx_battles_created_at ON battles(created_at DESC);

-- ============================================
-- 9. MISSIONS TABLE (미션 정의)
-- ============================================
CREATE TABLE missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    mission_type VARCHAR(50) NOT NULL,
    target_value INTEGER DEFAULT 1,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for missions
CREATE INDEX idx_missions_active ON missions(active);

-- ============================================
-- 10. USER_MISSIONS TABLE (사용자 미션 진행)
-- ============================================
CREATE TABLE user_missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    mission_id UUID NOT NULL REFERENCES missions(id) ON DELETE CASCADE,
    current_progress INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    claimed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, mission_id)
);

-- Indexes for user_missions
CREATE INDEX idx_user_missions_user_id ON user_missions(user_id);
CREATE INDEX idx_user_missions_mission_id ON user_missions(mission_id);
CREATE INDEX idx_user_missions_completed ON user_missions(completed);

-- ============================================
-- 11. ACHIEVEMENTS TABLE (업적 정의)
-- ============================================
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    achievement_type VARCHAR(50) NOT NULL,
    target_value INTEGER DEFAULT 1,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    icon VARCHAR(50),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for achievements
CREATE INDEX idx_achievements_active ON achievements(active);

-- ============================================
-- 12. USER_ACHIEVEMENTS TABLE (사용자 업적)
-- ============================================
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    current_progress INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    claimed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, achievement_id)
);

-- Indexes for user_achievements
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement_id ON user_achievements(achievement_id);
CREATE INDEX idx_user_achievements_completed ON user_achievements(completed);

-- ============================================
-- 13. CHAT_MESSAGES TABLE (채팅 메시지)
-- ============================================
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    username VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    chat_type VARCHAR(50) DEFAULT 'global',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for chat_messages
CREATE INDEX idx_chat_messages_chat_type ON chat_messages(chat_type);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);

-- ============================================
-- 14. USER_ACTIVITIES TABLE (사용자 활동 로그)
-- ============================================
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL,
    gold_change BIGINT DEFAULT 0,
    money_change BIGINT DEFAULT 0,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for user_activities
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_activity_type ON user_activities(activity_type);
CREATE INDEX idx_user_activities_created_at ON user_activities(created_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_swords ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_weapon_discoveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE roulette_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE battles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view all profiles for ranking" ON profiles
    FOR SELECT USING (true);

-- User swords policies
CREATE POLICY "Users can view their own swords" ON user_swords
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own swords" ON user_swords
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own swords" ON user_swords
    FOR DELETE USING (auth.uid() = user_id);

-- User weapon discoveries policies
CREATE POLICY "Users can view their own discoveries" ON user_weapon_discoveries
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own discoveries" ON user_weapon_discoveries
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own discoveries" ON user_weapon_discoveries
    FOR UPDATE USING (auth.uid() = user_id);

-- User items policies
CREATE POLICY "Users can view their own items" ON user_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own items" ON user_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own items" ON user_items
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own items" ON user_items
    FOR DELETE USING (auth.uid() = user_id);

-- Roulette games policies
CREATE POLICY "Users can view their own roulette games" ON roulette_games
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own roulette games" ON roulette_games
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Battles policies
CREATE POLICY "Users can view battles they participated in" ON battles
    FOR SELECT USING (auth.uid() = player1_id OR auth.uid() = player2_id);

CREATE POLICY "Users can insert battles" ON battles
    FOR INSERT WITH CHECK (auth.uid() = player1_id OR auth.uid() = player2_id);

-- User missions policies
CREATE POLICY "Users can view their own missions" ON user_missions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own missions" ON user_missions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own missions" ON user_missions
    FOR UPDATE USING (auth.uid() = user_id);

-- User achievements policies
CREATE POLICY "Users can view their own achievements" ON user_achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own achievements" ON user_achievements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own achievements" ON user_achievements
    FOR UPDATE USING (auth.uid() = user_id);

-- Chat messages policies
CREATE POLICY "Anyone can view chat messages" ON chat_messages
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own messages" ON chat_messages
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User activities policies
CREATE POLICY "Users can view their own activities" ON user_activities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own activities" ON user_activities
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Public read access for reference tables
ALTER TABLE sword_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view sword data" ON sword_data FOR SELECT USING (true);

ALTER TABLE reward_codes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active reward codes" ON reward_codes 
    FOR SELECT USING (active = true);

ALTER TABLE missions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active missions" ON missions 
    FOR SELECT USING (active = true);

ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active achievements" ON achievements 
    FOR SELECT USING (active = true);

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_weapon_discoveries_updated_at BEFORE UPDATE ON user_weapon_discoveries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_items_updated_at BEFORE UPDATE ON user_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to get user activity stats (for GM panel)
CREATE OR REPLACE FUNCTION get_user_activity_stats(target_user_id UUID)
RETURNS TABLE (
    activity_type VARCHAR,
    total_count BIGINT,
    total_gold_gained BIGINT,
    total_gold_lost BIGINT,
    total_money_gained BIGINT,
    total_money_lost BIGINT,
    net_gold_change BIGINT,
    net_money_change BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ua.activity_type,
        COUNT(*)::BIGINT as total_count,
        SUM(CASE WHEN ua.gold_change > 0 THEN ua.gold_change ELSE 0 END)::BIGINT as total_gold_gained,
        ABS(SUM(CASE WHEN ua.gold_change < 0 THEN ua.gold_change ELSE 0 END))::BIGINT as total_gold_lost,
        SUM(CASE WHEN ua.money_change > 0 THEN ua.money_change ELSE 0 END)::BIGINT as total_money_gained,
        ABS(SUM(CASE WHEN ua.money_change < 0 THEN ua.money_change ELSE 0 END))::BIGINT as total_money_lost,
        SUM(ua.gold_change)::BIGINT as net_gold_change,
        SUM(ua.money_change)::BIGINT as net_money_change
    FROM user_activities ua
    WHERE ua.user_id = target_user_id
    GROUP BY ua.activity_type
    ORDER BY total_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent user activities (for GM panel)
CREATE OR REPLACE FUNCTION get_recent_user_activities(target_user_id UUID, limit_count INTEGER DEFAULT 100)
RETURNS TABLE (
    id UUID,
    activity_type VARCHAR,
    gold_change BIGINT,
    money_change BIGINT,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ua.id,
        ua.activity_type,
        ua.gold_change,
        ua.money_change,
        ua.details,
        ua.created_at
    FROM user_activities ua
    WHERE ua.user_id = target_user_id
    ORDER BY ua.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert sample missions
INSERT INTO missions (title, description, mission_type, target_value, reward_gold, reward_money, active) VALUES
('첫 강화 성공', '검을 처음으로 강화하세요', 'enhance_success', 1, 5000, 0, true),
('강화 마스터', '검을 10번 강화하세요', 'enhance_count', 10, 50000, 5, true),
('검 수집가', '검을 5개 보관하세요', 'sword_collection', 5, 25000, 0, true),
('룰렛 도전', '룰렛을 5번 플레이하세요', 'roulette_play', 5, 10000, 0, true),
('배틀 승리', '배틀에서 3번 승리하세요', 'battle_win', 3, 30000, 0, true);

-- Insert sample achievements
INSERT INTO achievements (title, description, achievement_type, target_value, reward_gold, reward_money, icon, active) VALUES
('초보 강화사', '검을 +5까지 강화하세요', 'max_level', 5, 10000, 0, '⚔️', true),
('중급 강화사', '검을 +10까지 강화하세요', 'max_level', 10, 50000, 5, '⚔️', true),
('고급 강화사', '검을 +15까지 강화하세요', 'max_level', 15, 200000, 20, '⚔️', true),
('전설의 강화사', '검을 +20까지 강화하세요', 'max_level', 20, 1000000, 100, '⚔️', true),
('백만장자', '골드 1,000,000G를 모으세요', 'gold_earned', 1000000, 100000, 10, '💰', true),
('파괴왕', '검을 10번 파괴하세요', 'sword_destroy', 10, 50000, 5, '💥', true);

-- Insert sample reward codes
INSERT INTO reward_codes (code, reward_gold, reward_money, max_uses, active, expires_at) VALUES
('WELCOME2024', 10000, 5, 1000, true, NOW() + INTERVAL '30 days'),
('NEWBIE', 5000, 0, 1, true, NOW() + INTERVAL '90 days'),
('EVENT100', 100000, 10, 100, true, NOW() + INTERVAL '7 days');

-- ============================================
-- GRANTS (Ensure proper permissions)
-- ============================================

-- Grant usage on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- Grant permissions on tables
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON sword_data, missions, achievements, reward_codes TO anon;

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

-- Schema creation completed successfully
-- Next steps:
-- 1. Run this SQL in your Supabase SQL Editor
-- 2. Update the anon key in all HTML files
-- 3. Test user registration and login
-- 4. Verify all game features work correctly
