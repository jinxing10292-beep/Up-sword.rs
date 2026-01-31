-- ============================================
-- Up Sword Game - Database Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PROFILES TABLE (사용자 프로필)
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
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
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_nickname ON profiles(nickname);
CREATE INDEX IF NOT EXISTS idx_profiles_gold ON profiles(gold DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_current_sword_lvl ON profiles(current_sword_lvl DESC);

-- ============================================
-- 2. SWORD_DATA TABLE (검 데이터)
-- ============================================
CREATE TABLE IF NOT EXISTS sword_data (
    id SERIAL PRIMARY KEY,
    level INTEGER UNIQUE NOT NULL CHECK (level >= 0 AND level <= 20),
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. USER_SWORDS TABLE (사용자 보관 검)
-- ============================================
CREATE TABLE IF NOT EXISTS user_swords (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    sword_id VARCHAR(100) NOT NULL,
    sword_level INTEGER NOT NULL CHECK (sword_level >= 0 AND sword_level <= 20),
    weapon_type VARCHAR(50) DEFAULT 'normal',
    weapon_key VARCHAR(50) DEFAULT 'sword_01',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_swords_user_id ON user_swords(user_id);
CREATE INDEX IF NOT EXISTS idx_user_swords_sword_level ON user_swords(sword_level DESC);

-- ============================================
-- 4. USER_WEAPON_DISCOVERIES TABLE (무기 발견 기록)
-- ============================================
CREATE TABLE IF NOT EXISTS user_weapon_discoveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    weapon_type VARCHAR(50) NOT NULL,
    max_discovered_level INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, weapon_type)
);

CREATE INDEX IF NOT EXISTS idx_user_weapon_discoveries_user_id ON user_weapon_discoveries(user_id);

-- ============================================
-- 5. USER_ITEMS TABLE (사용자 아이템)
-- ============================================
CREATE TABLE IF NOT EXISTS user_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    item_id VARCHAR(100) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_type VARCHAR(50),
    quantity INTEGER DEFAULT 1 CHECK (quantity >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_items_user_id ON user_items(user_id);
CREATE INDEX IF NOT EXISTS idx_user_items_item_id ON user_items(item_id);

-- ============================================
-- 6. REWARD_CODES TABLE (보상 코드)
-- ============================================
CREATE TABLE IF NOT EXISTS reward_codes (
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

CREATE INDEX IF NOT EXISTS idx_reward_codes_code ON reward_codes(code);
CREATE INDEX IF NOT EXISTS idx_reward_codes_active ON reward_codes(active);

-- ============================================
-- 7. ROULETTE_GAMES TABLE (룰렛 게임 기록)
-- ============================================
CREATE TABLE IF NOT EXISTS roulette_games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    bet_amount BIGINT NOT NULL,
    bet_type VARCHAR(50) NOT NULL,
    result VARCHAR(50) NOT NULL,
    payout BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_roulette_games_user_id ON roulette_games(user_id);
CREATE INDEX IF NOT EXISTS idx_roulette_games_created_at ON roulette_games(created_at DESC);

-- ============================================
-- 8. BATTLES TABLE (배틀 기록)
-- ============================================
CREATE TABLE IF NOT EXISTS battles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    player2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    winner_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    player1_sword_level INTEGER,
    player2_sword_level INTEGER,
    bet_amount BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_battles_player1_id ON battles(player1_id);
CREATE INDEX IF NOT EXISTS idx_battles_player2_id ON battles(player2_id);
CREATE INDEX IF NOT EXISTS idx_battles_created_at ON battles(created_at DESC);

-- ============================================
-- 9. MISSIONS TABLE (미션 정의)
-- ============================================
CREATE TABLE IF NOT EXISTS missions (
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

CREATE INDEX IF NOT EXISTS idx_missions_active ON missions(active);

-- ============================================
-- 10. USER_MISSIONS TABLE (사용자 미션 진행)
-- ============================================
CREATE TABLE IF NOT EXISTS user_missions (
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

CREATE INDEX IF NOT EXISTS idx_user_missions_user_id ON user_missions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_missions_mission_id ON user_missions(mission_id);
CREATE INDEX IF NOT EXISTS idx_user_missions_completed ON user_missions(completed);

-- ============================================
-- 11. ACHIEVEMENTS TABLE (업적 정의)
-- ============================================
CREATE TABLE IF NOT EXISTS achievements (
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

CREATE INDEX IF NOT EXISTS idx_achievements_active ON achievements(active);

-- ============================================
-- 12. USER_ACHIEVEMENTS TABLE (사용자 업적)
-- ============================================
CREATE TABLE IF NOT EXISTS user_achievements (
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

CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_completed ON user_achievements(completed);

-- ============================================
-- 13. CHAT_MESSAGES TABLE (채팅 메시지)
-- ============================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    username VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    chat_type VARCHAR(50) DEFAULT 'global',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_chat_type ON chat_messages(chat_type);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);

-- ============================================
-- 14. USER_ACTIVITIES TABLE (사용자 활동 로그)
-- ============================================
CREATE TABLE IF NOT EXISTS user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL,
    gold_change BIGINT DEFAULT 0,
    money_change BIGINT DEFAULT 0,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activities_activity_type ON user_activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_user_activities_created_at ON user_activities(created_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS
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
ALTER TABLE sword_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Anyone can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can insert own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can delete own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can view own discoveries" ON user_weapon_discoveries;
DROP POLICY IF EXISTS "Users can insert own discoveries" ON user_weapon_discoveries;
DROP POLICY IF EXISTS "Users can update own discoveries" ON user_weapon_discoveries;
DROP POLICY IF EXISTS "Users can view own items" ON user_items;
DROP POLICY IF EXISTS "Users can insert own items" ON user_items;
DROP POLICY IF EXISTS "Users can update own items" ON user_items;
DROP POLICY IF EXISTS "Users can delete own items" ON user_items;
DROP POLICY IF EXISTS "Users can view own roulette games" ON roulette_games;
DROP POLICY IF EXISTS "Users can insert own roulette games" ON roulette_games;
DROP POLICY IF EXISTS "Users can view participated battles" ON battles;
DROP POLICY IF EXISTS "Users can insert battles" ON battles;
DROP POLICY IF EXISTS "Users can view own missions" ON user_missions;
DROP POLICY IF EXISTS "Users can insert own missions" ON user_missions;
DROP POLICY IF EXISTS "Users can update own missions" ON user_missions;
DROP POLICY IF EXISTS "Users can view own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can insert own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can update own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Anyone can view chat messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can insert own messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can view own activities" ON user_activities;
DROP POLICY IF EXISTS "Users can insert own activities" ON user_activities;
DROP POLICY IF EXISTS "Anyone can view sword data" ON sword_data;
DROP POLICY IF EXISTS "Anyone can view active reward codes" ON reward_codes;
DROP POLICY IF EXISTS "Anyone can view active missions" ON missions;
DROP POLICY IF EXISTS "Anyone can view active achievements" ON achievements;

-- Profiles policies
CREATE POLICY "Anyone can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- User swords policies
CREATE POLICY "Users can view own swords" ON user_swords FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own swords" ON user_swords FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own swords" ON user_swords FOR DELETE USING (auth.uid() = user_id);

-- User weapon discoveries policies
CREATE POLICY "Users can view own discoveries" ON user_weapon_discoveries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own discoveries" ON user_weapon_discoveries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own discoveries" ON user_weapon_discoveries FOR UPDATE USING (auth.uid() = user_id);

-- User items policies
CREATE POLICY "Users can view own items" ON user_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own items" ON user_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own items" ON user_items FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own items" ON user_items FOR DELETE USING (auth.uid() = user_id);

-- Roulette games policies
CREATE POLICY "Users can view own roulette games" ON roulette_games FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own roulette games" ON roulette_games FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Battles policies
CREATE POLICY "Users can view participated battles" ON battles FOR SELECT USING (auth.uid() = player1_id OR auth.uid() = player2_id);
CREATE POLICY "Users can insert battles" ON battles FOR INSERT WITH CHECK (auth.uid() = player1_id OR auth.uid() = player2_id);

-- User missions policies
CREATE POLICY "Users can view own missions" ON user_missions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own missions" ON user_missions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own missions" ON user_missions FOR UPDATE USING (auth.uid() = user_id);

-- User achievements policies
CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own achievements" ON user_achievements FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own achievements" ON user_achievements FOR UPDATE USING (auth.uid() = user_id);

-- Chat messages policies
CREATE POLICY "Anyone can view chat messages" ON chat_messages FOR SELECT USING (true);
CREATE POLICY "Users can insert own messages" ON chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User activities policies
CREATE POLICY "Users can view own activities" ON user_activities FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own activities" ON user_activities FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Public read access for reference tables
CREATE POLICY "Anyone can view sword data" ON sword_data FOR SELECT USING (true);
CREATE POLICY "Anyone can view active reward codes" ON reward_codes FOR SELECT USING (active = true);
CREATE POLICY "Anyone can view active missions" ON missions FOR SELECT USING (active = true);
CREATE POLICY "Anyone can view active achievements" ON achievements FOR SELECT USING (active = true);

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
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_weapon_discoveries_updated_at ON user_weapon_discoveries;
CREATE TRIGGER update_user_weapon_discoveries_updated_at BEFORE UPDATE ON user_weapon_discoveries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_items_updated_at ON user_items;
CREATE TRIGGER update_user_items_updated_at BEFORE UPDATE ON user_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
