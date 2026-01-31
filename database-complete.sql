-- ============================================
-- Up Sword 게임 전체 데이터베이스 설정 (완전판)
-- Supabase SQL Editor에서 실행하세요
-- ============================================

-- ============================================
-- 테이블 생성
-- ============================================

-- 1. profiles 테이블 (사용자 프로필)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname TEXT UNIQUE NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    gold BIGINT DEFAULT 10000,
    money BIGINT DEFAULT 0,
    current_sword_lvl INTEGER DEFAULT 0,
    is_banned BOOLEAN DEFAULT FALSE,
    ban_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. sword_data 테이블 (검 데이터)
CREATE TABLE IF NOT EXISTS sword_data (
    id SERIAL PRIMARY KEY,
    level INTEGER UNIQUE NOT NULL,
    name TEXT NOT NULL,
    image_url TEXT,
    price BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. user_swords 테이블 (사용자가 보유한 검)
CREATE TABLE IF NOT EXISTS user_swords (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    sword_level INTEGER NOT NULL,
    sword_name TEXT NOT NULL,
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, sword_level)
);

-- 4. reward_codes 테이블 (보상 코드)
CREATE TABLE IF NOT EXISTS reward_codes (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. user_reward_codes 테이블 (사용자가 사용한 보상 코드)
CREATE TABLE IF NOT EXISTS user_reward_codes (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, code)
);

-- 6. battles 테이블 (배틀 기록)
CREATE TABLE IF NOT EXISTS battles (
    id SERIAL PRIMARY KEY,
    player1_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    player2_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    player1_sword_level INTEGER,
    player2_sword_level INTEGER,
    winner_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. battle_logs 테이블 (배틀 상세 로그)
CREATE TABLE IF NOT EXISTS battle_logs (
    id SERIAL PRIMARY KEY,
    battle_id INTEGER REFERENCES battles(id) ON DELETE CASCADE,
    round INTEGER NOT NULL,
    attacker_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    defender_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    damage INTEGER NOT NULL,
    attacker_hp INTEGER NOT NULL,
    defender_hp INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. support_tickets 테이블 (고객 지원 티켓)
CREATE TABLE IF NOT EXISTS support_tickets (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    content TEXT NOT NULL,
    nickname TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. roulette_history 테이블 (룰렛 기록)
CREATE TABLE IF NOT EXISTS roulette_history (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    bet_amount BIGINT NOT NULL,
    bet_type TEXT NOT NULL,
    result TEXT NOT NULL,
    win_amount BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. shop_items 테이블 (상점 아이템)
CREATE TABLE IF NOT EXISTS shop_items (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price_gold BIGINT DEFAULT 0,
    price_money BIGINT DEFAULT 0,
    item_type TEXT NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. user_inventory 테이블 (사용자 인벤토리)
CREATE TABLE IF NOT EXISTS user_inventory (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES shop_items(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, item_id)
);

-- 12. achievements 테이블 (업적 정의)
CREATE TABLE IF NOT EXISTS achievements (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    condition_type TEXT NOT NULL,
    condition_value INTEGER NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. user_achievements 테이블 (사용자 업적)
CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE CASCADE,
    progress INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, achievement_id)
);

-- 14. achievement_milestones 테이블 (업적 마일스톤)
CREATE TABLE IF NOT EXISTS achievement_milestones (
    id SERIAL PRIMARY KEY,
    milestone_count INTEGER UNIQUE NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 15. user_achievement_milestones 테이블 (사용자 마일스톤)
CREATE TABLE IF NOT EXISTS user_achievement_milestones (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    milestone_id INTEGER REFERENCES achievement_milestones(id) ON DELETE CASCADE,
    claimed BOOLEAN DEFAULT FALSE,
    claimed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, milestone_id)
);

-- 16. missions 테이블 (미션 정의)
CREATE TABLE IF NOT EXISTS missions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    mission_type TEXT NOT NULL,
    target_value INTEGER NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 17. user_missions 테이블 (사용자 미션)
CREATE TABLE IF NOT EXISTS user_missions (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    mission_id INTEGER REFERENCES missions(id) ON DELETE CASCADE,
    progress INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, mission_id)
);

-- ============================================
-- RLS (Row Level Security) 활성화 및 정책 설정
-- ============================================

-- 1. profiles 테이블 RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. sword_data 테이블 RLS (공개 읽기)
ALTER TABLE sword_data ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view sword data" ON sword_data;
CREATE POLICY "Anyone can view sword data" ON sword_data 
    FOR SELECT USING (true);

-- 3. user_swords 테이블 RLS
ALTER TABLE user_swords ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own swords" ON user_swords;
CREATE POLICY "Users can view own swords" ON user_swords
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own swords" ON user_swords;
CREATE POLICY "Users can insert own swords" ON user_swords
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own swords" ON user_swords;
CREATE POLICY "Users can update own swords" ON user_swords
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own swords" ON user_swords;
CREATE POLICY "Users can delete own swords" ON user_swords
    FOR DELETE USING (auth.uid() = user_id);

-- 4. reward_codes 테이블 RLS
ALTER TABLE reward_codes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active reward codes" ON reward_codes;
CREATE POLICY "Anyone can view active reward codes" ON reward_codes
    FOR SELECT USING (active = true);

-- 5. user_reward_codes 테이블 RLS
ALTER TABLE user_reward_codes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own reward codes" ON user_reward_codes;
CREATE POLICY "Users can view own reward codes" ON user_reward_codes
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own reward codes" ON user_reward_codes;
CREATE POLICY "Users can insert own reward codes" ON user_reward_codes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. battles 테이블 RLS
ALTER TABLE battles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own battles" ON battles;
CREATE POLICY "Users can view own battles" ON battles
    FOR SELECT USING (auth.uid() = player1_id OR auth.uid() = player2_id);

DROP POLICY IF EXISTS "Users can insert battles" ON battles;
CREATE POLICY "Users can insert battles" ON battles
    FOR INSERT WITH CHECK (auth.uid() = player1_id);

-- 7. battle_logs 테이블 RLS
ALTER TABLE battle_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view battle logs" ON battle_logs;
CREATE POLICY "Users can view battle logs" ON battle_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM battles 
            WHERE battles.id = battle_logs.battle_id 
            AND (battles.player1_id = auth.uid() OR battles.player2_id = auth.uid())
        )
    );

DROP POLICY IF EXISTS "Users can insert battle logs" ON battle_logs;
CREATE POLICY "Users can insert battle logs" ON battle_logs
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM battles 
            WHERE battles.id = battle_logs.battle_id 
            AND battles.player1_id = auth.uid()
        )
    );

-- 8. support_tickets 테이블 RLS
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view tickets" ON support_tickets;
CREATE POLICY "Users can view tickets" ON support_tickets
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert tickets" ON support_tickets;
CREATE POLICY "Users can insert tickets" ON support_tickets
    FOR INSERT WITH CHECK (true);

-- 9. roulette_history 테이블 RLS
ALTER TABLE roulette_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own roulette history" ON roulette_history;
CREATE POLICY "Users can view own roulette history" ON roulette_history
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own roulette history" ON roulette_history;
CREATE POLICY "Users can insert own roulette history" ON roulette_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 10. shop_items 테이블 RLS (공개 읽기)
ALTER TABLE shop_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view shop items" ON shop_items;
CREATE POLICY "Anyone can view shop items" ON shop_items 
    FOR SELECT USING (true);

-- 11. user_inventory 테이블 RLS
ALTER TABLE user_inventory ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own inventory" ON user_inventory;
CREATE POLICY "Users can view own inventory" ON user_inventory
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own inventory" ON user_inventory;
CREATE POLICY "Users can manage own inventory" ON user_inventory
    FOR ALL USING (auth.uid() = user_id);

-- 12. achievements 테이블 RLS (공개 읽기)
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view achievements" ON achievements;
CREATE POLICY "Anyone can view achievements" ON achievements 
    FOR SELECT USING (true);

-- 13. user_achievements 테이블 RLS
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own achievements" ON user_achievements;
CREATE POLICY "Users can view own achievements" ON user_achievements
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own achievements" ON user_achievements;
CREATE POLICY "Users can manage own achievements" ON user_achievements
    FOR ALL USING (auth.uid() = user_id);

-- 14. achievement_milestones 테이블 RLS (공개 읽기)
ALTER TABLE achievement_milestones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view milestones" ON achievement_milestones;
CREATE POLICY "Anyone can view milestones" ON achievement_milestones 
    FOR SELECT USING (true);

-- 15. user_achievement_milestones 테이블 RLS
ALTER TABLE user_achievement_milestones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own milestones" ON user_achievement_milestones;
CREATE POLICY "Users can view own milestones" ON user_achievement_milestones
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own milestones" ON user_achievement_milestones;
CREATE POLICY "Users can manage own milestones" ON user_achievement_milestones
    FOR ALL USING (auth.uid() = user_id);

-- 16. missions 테이블 RLS (공개 읽기)
ALTER TABLE missions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view missions" ON missions;
CREATE POLICY "Anyone can view missions" ON missions 
    FOR SELECT USING (true);

-- 17. user_missions 테이블 RLS
ALTER TABLE user_missions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own missions" ON user_missions;
CREATE POLICY "Users can view own missions" ON user_missions
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own missions" ON user_missions;
CREATE POLICY "Users can manage own missions" ON user_missions
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- 트리거 함수
-- ============================================

-- updated_at 자동 갱신 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- profiles 테이블 트리거
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 인덱스 생성 (성능 최적화)
-- ============================================

CREATE INDEX IF NOT EXISTS idx_profiles_nickname ON profiles(nickname);
CREATE INDEX IF NOT EXISTS idx_profiles_phone ON profiles(phone);
CREATE INDEX IF NOT EXISTS idx_user_swords_user_id ON user_swords(user_id);
CREATE INDEX IF NOT EXISTS idx_user_swords_sword_level ON user_swords(sword_level);
CREATE INDEX IF NOT EXISTS idx_battles_player1 ON battles(player1_id);
CREATE INDEX IF NOT EXISTS idx_battles_player2 ON battles(player2_id);
CREATE INDEX IF NOT EXISTS idx_battles_created_at ON battles(created_at);
CREATE INDEX IF NOT EXISTS idx_battle_logs_battle_id ON battle_logs(battle_id);
CREATE INDEX IF NOT EXISTS idx_roulette_history_user_id ON roulette_history(user_id);
CREATE INDEX IF NOT EXISTS idx_roulette_history_created_at ON roulette_history(created_at);
CREATE INDEX IF NOT EXISTS idx_user_inventory_user_id ON user_inventory(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_missions_user_id ON user_missions(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_at ON support_tickets(created_at);
CREATE INDEX IF NOT EXISTS idx_user_reward_codes_user_id ON user_reward_codes(user_id);

-- ============================================
-- Storage 버킷 생성 안내
-- ============================================

-- Supabase Dashboard > Storage에서 수동으로 생성:
-- 1. 버킷 이름: codet-img
-- 2. Public 설정: true
-- 3. 파일 크기 제한: 5MB
-- 4. 허용 파일 형식: image/*

-- ============================================
-- 완료!
-- ============================================

-- 이 스크립트는 다음을 포함합니다:
-- ✅ 17개 테이블 생성
-- ✅ 모든 테이블에 RLS 활성화
-- ✅ 보안 정책 설정 (사용자별 데이터 접근 제어)
-- ✅ 자동 업데이트 트리거
-- ✅ 성능 최적화 인덱스
-- ✅ DROP POLICY IF EXISTS로 재실행 가능
