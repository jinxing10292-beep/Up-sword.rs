-- ============================================
-- Up Sword 게임 완전한 데이터베이스 설정
-- Supabase SQL Editor에서 이 파일 전체를 실행하세요
-- 테이블 생성부터 데이터 삽입까지 모두 포함
-- ============================================

-- ============================================
-- 1. 테이블 생성
-- ============================================

-- profiles 테이블 (사용자 프로필)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname TEXT UNIQUE NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    gold BIGINT DEFAULT 10000,
    money BIGINT DEFAULT 0,
    current_sword_lvl INTEGER DEFAULT 0,
    current_weapon_type TEXT DEFAULT 'normal',
    is_banned BOOLEAN DEFAULT FALSE,
    ban_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- sword_data 테이블 (검 데이터)
CREATE TABLE IF NOT EXISTS sword_data (
    id SERIAL PRIMARY KEY,
    level INTEGER UNIQUE NOT NULL,
    name TEXT NOT NULL,
    image_url TEXT,
    price BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- user_swords 테이블 (사용자가 보유한 검)
CREATE TABLE IF NOT EXISTS user_swords (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    sword_level INTEGER NOT NULL,
    sword_name TEXT NOT NULL,
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, sword_level)
);

-- reward_codes 테이블 (보상 코드)
CREATE TABLE IF NOT EXISTS reward_codes (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- user_reward_codes 테이블 (사용자가 사용한 보상 코드)
CREATE TABLE IF NOT EXISTS user_reward_codes (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, code)
);

-- battles 테이블 (배틀 기록)
CREATE TABLE IF NOT EXISTS battles (
    id SERIAL PRIMARY KEY,
    player1_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    player2_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    player1_sword_level INTEGER,
    player2_sword_level INTEGER,
    winner_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- battle_logs 테이블 (배틀 상세 로그)
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

-- support_tickets 테이블 (고객 지원 티켓)
CREATE TABLE IF NOT EXISTS support_tickets (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    content TEXT NOT NULL,
    nickname TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- roulette_history 테이블 (룰렛 기록)
CREATE TABLE IF NOT EXISTS roulette_history (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    bet_amount BIGINT NOT NULL,
    bet_type TEXT NOT NULL,
    result TEXT NOT NULL,
    win_amount BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- shop_items 테이블 (상점 아이템)
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

-- user_inventory 테이블 (사용자 인벤토리)
CREATE TABLE IF NOT EXISTS user_inventory (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES shop_items(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, item_id)
);

-- achievements 테이블 (업적 정의)
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

-- user_achievements 테이블 (사용자 업적)
CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE CASCADE,
    progress INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, achievement_id)
);

-- achievement_milestones 테이블 (업적 마일스톤)
CREATE TABLE IF NOT EXISTS achievement_milestones (
    id SERIAL PRIMARY KEY,
    milestone_count INTEGER UNIQUE NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- user_achievement_milestones 테이블 (사용자 마일스톤)
CREATE TABLE IF NOT EXISTS user_achievement_milestones (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    milestone_id INTEGER REFERENCES achievement_milestones(id) ON DELETE CASCADE,
    claimed BOOLEAN DEFAULT FALSE,
    claimed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, milestone_id)
);

-- missions 테이블 (미션 정의)
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

-- user_missions 테이블 (사용자 미션)
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
-- 2. RLS (Row Level Security) 활성화 및 정책 설정
-- ============================================

-- profiles 테이블
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Anyone can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- sword_data 테이블
ALTER TABLE sword_data ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view sword data" ON sword_data;
CREATE POLICY "Anyone can view sword data" ON sword_data FOR SELECT USING (true);

-- user_swords 테이블
ALTER TABLE user_swords ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can insert own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can update own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can delete own swords" ON user_swords;

CREATE POLICY "Users can view own swords" ON user_swords FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own swords" ON user_swords FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own swords" ON user_swords FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own swords" ON user_swords FOR DELETE USING (auth.uid() = user_id);

-- reward_codes 테이블
ALTER TABLE reward_codes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active reward codes" ON reward_codes;
CREATE POLICY "Anyone can view active reward codes" ON reward_codes FOR SELECT USING (active = true);

-- user_reward_codes 테이블
ALTER TABLE user_reward_codes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own reward codes" ON user_reward_codes;
DROP POLICY IF EXISTS "Users can insert own reward codes" ON user_reward_codes;

CREATE POLICY "Users can view own reward codes" ON user_reward_codes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own reward codes" ON user_reward_codes FOR INSERT WITH CHECK (auth.uid() = user_id);

-- battles 테이블
ALTER TABLE battles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own battles" ON battles;
DROP POLICY IF EXISTS "Users can insert battles" ON battles;

CREATE POLICY "Users can view own battles" ON battles FOR SELECT USING (auth.uid() = player1_id OR auth.uid() = player2_id);
CREATE POLICY "Users can insert battles" ON battles FOR INSERT WITH CHECK (auth.uid() = player1_id);

-- battle_logs 테이블
ALTER TABLE battle_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view battle logs" ON battle_logs;
DROP POLICY IF EXISTS "Users can insert battle logs" ON battle_logs;

CREATE POLICY "Users can view battle logs" ON battle_logs FOR SELECT USING (
    EXISTS (SELECT 1 FROM battles WHERE battles.id = battle_logs.battle_id AND (battles.player1_id = auth.uid() OR battles.player2_id = auth.uid()))
);
CREATE POLICY "Users can insert battle logs" ON battle_logs FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM battles WHERE battles.id = battle_logs.battle_id AND battles.player1_id = auth.uid())
);

-- support_tickets 테이블
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view tickets" ON support_tickets;
DROP POLICY IF EXISTS "Users can insert tickets" ON support_tickets;

CREATE POLICY "Users can view tickets" ON support_tickets FOR SELECT USING (true);
CREATE POLICY "Users can insert tickets" ON support_tickets FOR INSERT WITH CHECK (true);

-- roulette_history 테이블
ALTER TABLE roulette_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own roulette history" ON roulette_history;
DROP POLICY IF EXISTS "Users can insert own roulette history" ON roulette_history;

CREATE POLICY "Users can view own roulette history" ON roulette_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own roulette history" ON roulette_history FOR INSERT WITH CHECK (auth.uid() = user_id);

-- shop_items 테이블
ALTER TABLE shop_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view shop items" ON shop_items;
CREATE POLICY "Anyone can view shop items" ON shop_items FOR SELECT USING (true);

-- user_inventory 테이블
ALTER TABLE user_inventory ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own inventory" ON user_inventory;
DROP POLICY IF EXISTS "Users can manage own inventory" ON user_inventory;

CREATE POLICY "Users can view own inventory" ON user_inventory FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own inventory" ON user_inventory FOR ALL USING (auth.uid() = user_id);

-- achievements 테이블
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view achievements" ON achievements;
CREATE POLICY "Anyone can view achievements" ON achievements FOR SELECT USING (true);

-- user_achievements 테이블
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can manage own achievements" ON user_achievements;

CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own achievements" ON user_achievements FOR ALL USING (auth.uid() = user_id);

-- achievement_milestones 테이블
ALTER TABLE achievement_milestones ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view milestones" ON achievement_milestones;
CREATE POLICY "Anyone can view milestones" ON achievement_milestones FOR SELECT USING (true);

-- user_achievement_milestones 테이블
ALTER TABLE user_achievement_milestones ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own milestones" ON user_achievement_milestones;
DROP POLICY IF EXISTS "Users can manage own milestones" ON user_achievement_milestones;

CREATE POLICY "Users can view own milestones" ON user_achievement_milestones FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own milestones" ON user_achievement_milestones FOR ALL USING (auth.uid() = user_id);

-- missions 테이블
ALTER TABLE missions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view missions" ON missions;
CREATE POLICY "Anyone can view missions" ON missions FOR SELECT USING (true);

-- user_missions 테이블
ALTER TABLE user_missions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own missions" ON user_missions;
DROP POLICY IF EXISTS "Users can manage own missions" ON user_missions;

CREATE POLICY "Users can view own missions" ON user_missions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own missions" ON user_missions FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- 3. 트리거 함수 및 트리거
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 4. 인덱스 생성 (성능 최적화)
-- ============================================

CREATE INDEX IF NOT EXISTS idx_profiles_nickname ON profiles(nickname);
CREATE INDEX IF NOT EXISTS idx_profiles_phone ON profiles(phone);
CREATE INDEX IF NOT EXISTS idx_profiles_gold ON profiles(gold DESC);
CREATE INDEX IF NOT EXISTS idx_user_swords_user_id ON user_swords(user_id);
CREATE INDEX IF NOT EXISTS idx_battles_player1 ON battles(player1_id);
CREATE INDEX IF NOT EXISTS idx_battles_player2 ON battles(player2_id);
CREATE INDEX IF NOT EXISTS idx_battle_logs_battle_id ON battle_logs(battle_id);
CREATE INDEX IF NOT EXISTS idx_roulette_history_user_id ON roulette_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_inventory_user_id ON user_inventory(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_missions_user_id ON user_missions(user_id);

-- ============================================
-- 5. 기본 데이터 삽입
-- ============================================

-- 검 데이터 (레벨 0-20)
INSERT INTO sword_data (level, name, price) VALUES
(0, '녹슨 검', 0),
(1, '낡은 검', 1000),
(2, '철 검', 2500),
(3, '강철 검', 5000),
(4, '은 검', 10000),
(5, '금 검', 20000),
(6, '다이아몬드 검', 40000),
(7, '에메랄드 검', 80000),
(8, '루비 검', 160000),
(9, '사파이어 검', 320000),
(10, '플래티넘 검', 640000),
(11, '미스릴 검', 1280000),
(12, '아다만타이트 검', 2560000),
(13, '오리하르콘 검', 5120000),
(14, '드래곤 검', 10240000),
(15, '전설의 검', 20480000),
(16, '신화의 검', 40960000),
(17, '불멸의 검', 81920000),
(18, '천상의 검', 163840000),
(19, '신성한 검', 327680000),
(20, '궁극의 검', 655360000)
ON CONFLICT (level) DO UPDATE SET name = EXCLUDED.name, price = EXCLUDED.price;

-- 업적 데이터
INSERT INTO achievements (name, description, icon, condition_type, condition_value, reward_gold, reward_money, active) VALUES
('첫 강화', '검을 처음으로 강화하세요', '⚔️', 'enhance', 1, 1000, 0, true),
('강화 마스터', '검을 10번 강화하세요', '🗡️', 'enhance', 10, 10000, 100, true),
('강화의 신', '검을 50번 강화하세요', '⚡', 'enhance', 50, 50000, 500, true),
('강화 전설', '검을 100번 강화하세요', '💫', 'enhance', 100, 100000, 1000, true),
('첫 승리', '배틀에서 처음으로 승리하세요', '🏆', 'battle_win', 1, 2000, 0, true),
('전투의 달인', '배틀에서 10번 승리하세요', '🎖️', 'battle_win', 10, 20000, 200, true),
('무적의 전사', '배틀에서 50번 승리하세요', '👑', 'battle_win', 50, 100000, 1000, true),
('전쟁의 신', '배틀에서 100번 승리하세요', '⚡', 'battle_win', 100, 200000, 2000, true),
('룰렛 입문', '룰렛을 처음으로 플레이하세요', '🎰', 'roulette', 1, 500, 0, true),
('도박꾼', '룰렛을 20번 플레이하세요', '🎲', 'roulette', 20, 10000, 100, true),
('카지노 왕', '룰렛을 100번 플레이하세요', '🃏', 'roulette', 100, 50000, 500, true),
('부자', '골드 100만을 모으세요', '💰', 'gold', 1000000, 50000, 500, true),
('백만장자', '골드 1000만을 모으세요', '💎', 'gold', 10000000, 100000, 1000, true),
('억만장자', '골드 1억을 모으세요', '👑', 'gold', 100000000, 500000, 5000, true),
('검 수집가', '10개의 검을 수집하세요', '📦', 'sword_collect', 10, 30000, 300, true),
('검 마스터', '20개의 검을 수집하세요', '🎁', 'sword_collect', 20, 100000, 1000, true)
ON CONFLICT DO NOTHING;

-- 업적 마일스톤
INSERT INTO achievement_milestones (milestone_count, reward_gold, reward_money) VALUES
(3, 5000, 50),
(5, 10000, 100),
(10, 25000, 250),
(15, 50000, 500),
(20, 100000, 1000),
(30, 200000, 2000),
(50, 500000, 5000)
ON CONFLICT (milestone_count) DO UPDATE SET reward_gold = EXCLUDED.reward_gold, reward_money = EXCLUDED.reward_money;

-- 미션 데이터
INSERT INTO missions (title, description, mission_type, target_value, reward_gold, reward_money, active) VALUES
('일일 강화', '오늘 검을 5번 강화하세요', 'daily_enhance', 5, 5000, 50, true),
('일일 배틀', '오늘 배틀을 3번 하세요', 'daily_battle', 3, 3000, 30, true),
('일일 룰렛', '오늘 룰렛을 10번 하세요', 'daily_roulette', 10, 10000, 100, true),
('주간 강화왕', '이번 주에 검을 30번 강화하세요', 'weekly_enhance', 30, 30000, 300, true),
('주간 전투왕', '이번 주에 배틀을 20번 하세요', 'weekly_battle', 20, 20000, 200, true),
('주간 도박왕', '이번 주에 룰렛을 50번 하세요', 'weekly_roulette', 50, 50000, 500, true)
ON CONFLICT DO NOTHING;

-- 상점 아이템
INSERT INTO shop_items (name, description, price_gold, price_money, item_type, active) VALUES
('확정 강화권', '다음 강화를 100% 성공시킵니다', 50000, 0, 'enhance_scroll', true),
('골드 부스터 (1시간)', '1시간 동안 골드 획득량 2배', 0, 100, 'gold_booster', true),
('경험치 부스터 (1시간)', '1시간 동안 경험치 획득량 2배', 0, 100, 'exp_booster', true),
('럭키 코인', '룰렛 당첨 확률 증가 (1회)', 100000, 0, 'lucky_coin', true),
('보호 주문서', '강화 실패 시 검 파괴 방지 (1회)', 200000, 0, 'protection_scroll', true),
('골드 팩 (소)', '골드 10만 획득', 0, 50, 'gold_pack_small', true),
('골드 팩 (중)', '골드 50만 획득', 0, 200, 'gold_pack_medium', true),
('골드 팩 (대)', '골드 100만 획득', 0, 350, 'gold_pack_large', true)
ON CONFLICT DO NOTHING;

-- 샘플 보상 코드
INSERT INTO reward_codes (code, reward_gold, reward_money, active) VALUES
('WELCOME2024', 50000, 100, true),
('NEWUSER', 10000, 0, true),
('GRANDOPEN', 100000, 500, true)
ON CONFLICT (code) DO UPDATE SET reward_gold = EXCLUDED.reward_gold, reward_money = EXCLUDED.reward_money, active = EXCLUDED.active;

-- ============================================
-- 완료!
-- ============================================

-- 설치 완료! 이제 다음을 확인하세요:
-- ✅ 17개 테이블 생성
-- ✅ 모든 RLS 정책 설정
-- ✅ 트리거 및 인덱스 생성
-- ✅ 검 21개, 업적 16개, 미션 6개, 상점 8개 데이터 삽입

-- 추가 설정:
-- 1. Supabase Dashboard > Authentication > Providers > Email
--    "Confirm email" 옵션 비활성화
-- 2. Storage에서 'codet-img' 버킷 생성 (Public: true)
