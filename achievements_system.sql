-- ============================================
-- 업적 시스템 테이블
-- ============================================

-- 1. achievements 테이블 (업적 정의)
-- 기존 테이블이 있다면 컬럼 추가
DO $$ 
BEGIN
    -- category 컬럼이 없으면 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'achievements' AND column_name = 'category'
    ) THEN
        ALTER TABLE achievements ADD COLUMN category TEXT DEFAULT 'general';
    END IF;
    
    -- reward_gold 컬럼이 없으면 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'achievements' AND column_name = 'reward_gold'
    ) THEN
        ALTER TABLE achievements ADD COLUMN reward_gold INTEGER DEFAULT 0;
    END IF;
    
    -- reward_money 컬럼이 없으면 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'achievements' AND column_name = 'reward_money'
    ) THEN
        ALTER TABLE achievements ADD COLUMN reward_money INTEGER DEFAULT 0;
    END IF;
END $$;

-- 테이블이 없으면 생성
CREATE TABLE IF NOT EXISTS achievements (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general', -- 'sword', 'gold', 'money', 'battle', 'roulette', 'general'
    target INTEGER NOT NULL DEFAULT 1,
    reward_gold INTEGER DEFAULT 0,
    reward_money INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. user_achievements 테이블 (사용자 업적 진행도)
CREATE TABLE IF NOT EXISTS user_achievements (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_id BIGINT NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    progress INTEGER DEFAULT 0,
    unlocked BOOLEAN DEFAULT false,
    unlocked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- 3. achievement_milestones 테이블 (마일스톤 보상)
CREATE TABLE IF NOT EXISTS achievement_milestones (
    id BIGSERIAL PRIMARY KEY,
    milestone_count INTEGER NOT NULL UNIQUE, -- 5, 10, 15, 20, etc.
    reward_gold INTEGER DEFAULT 0,
    reward_money INTEGER DEFAULT 0,
    reward_description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. user_achievement_milestones 테이블 (사용자 마일스톤 달성 기록)
CREATE TABLE IF NOT EXISTS user_achievement_milestones (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    milestone_id BIGINT NOT NULL REFERENCES achievement_milestones(id) ON DELETE CASCADE,
    claimed BOOLEAN DEFAULT false,
    claimed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, milestone_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_achievement_milestones_user_id ON user_achievement_milestones(user_id);

-- RLS 정책
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievement_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievement_milestones ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제 후 재생성
DROP POLICY IF EXISTS "Anyone can view achievements" ON achievements;
DROP POLICY IF EXISTS "Users can view their own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can insert their own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can update their own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Anyone can view milestones" ON achievement_milestones;
DROP POLICY IF EXISTS "Users can view their own milestone progress" ON user_achievement_milestones;
DROP POLICY IF EXISTS "Users can insert their own milestone progress" ON user_achievement_milestones;
DROP POLICY IF EXISTS "Users can update their own milestone progress" ON user_achievement_milestones;

-- achievements는 모두가 읽을 수 있음
CREATE POLICY "Anyone can view achievements"
    ON achievements FOR SELECT
    USING (true);

-- user_achievements는 본인 것만 읽기/쓰기
CREATE POLICY "Users can view their own achievements"
    ON user_achievements FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own achievements"
    ON user_achievements FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own achievements"
    ON user_achievements FOR UPDATE
    USING (auth.uid() = user_id);

-- achievement_milestones는 모두가 읽을 수 있음
CREATE POLICY "Anyone can view milestones"
    ON achievement_milestones FOR SELECT
    USING (true);

-- user_achievement_milestones는 본인 것만 읽기/쓰기
CREATE POLICY "Users can view their own milestone progress"
    ON user_achievement_milestones FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own milestone progress"
    ON user_achievement_milestones FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own milestone progress"
    ON user_achievement_milestones FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- 업적 데이터 삽입
-- ============================================

-- 기존 업적 삭제 (중복 방지)
DELETE FROM achievements WHERE category IN ('sword', 'gold', 'money', 'battle', 'roulette');

-- 검 관련 업적
INSERT INTO achievements (title, description, target, active, category, reward_gold, reward_money) VALUES
('검의 시작', '검을 +1 강화하세요', 1, true, 'sword', 1000, 0),
('초보 대장장이', '검을 +5 강화하세요', 5, true, 'sword', 5000, 0),
('숙련된 대장장이', '검을 +10 강화하세요', 10, true, 'sword', 20000, 5),
('마스터 대장장이', '검을 +15 강화하세요', 15, true, 'sword', 100000, 20),
('전설의 대장장이', '검을 +20 강화하세요', 20, true, 'sword', 500000, 100),
('강화 중독자', '총 100번 강화하세요', 100, true, 'sword', 50000, 10),
('강화 마니아', '총 500번 강화하세요', 500, true, 'sword', 200000, 50),
('강화의 신', '총 1000번 강화하세요', 1000, true, 'sword', 1000000, 200),
('검 수집가', '인벤토리에 검 10개를 보관하세요', 10, true, 'sword', 30000, 10),
('검 박물관', '인벤토리에 검 50개를 보관하세요', 50, true, 'sword', 200000, 50);

-- 골드 관련 업적
INSERT INTO achievements (title, description, target, active, category, reward_gold, reward_money) VALUES
('첫 재산', '골드 10,000G를 모으세요', 10000, true, 'gold', 5000, 0),
('부자의 시작', '골드 100,000G를 모으세요', 100000, true, 'gold', 20000, 5),
('백만장자', '골드 1,000,000G를 모으세요', 1000000, true, 'gold', 100000, 20),
('억만장자', '골드 10,000,000G를 모으세요', 10000000, true, 'gold', 500000, 100),
('골드 마스터', '골드 100,000,000G를 모으세요', 100000000, true, 'gold', 2000000, 500);

-- 머니 관련 업적
INSERT INTO achievements (title, description, target, active, category, reward_gold, reward_money) VALUES
('머니의 시작', '머니 10M을 모으세요', 10, true, 'money', 10000, 5),
('머니 수집가', '머니 100M을 모으세요', 100, true, 'money', 50000, 20),
('머니 부자', '머니 1,000M을 모으세요', 1000, true, 'money', 200000, 100),
('머니 재벌', '머니 10,000M을 모으세요', 10000, true, 'money', 1000000, 500),
('머니 황제', '머니 100,000M을 모으세요', 100000, true, 'money', 5000000, 2000);

-- 전투 관련 업적
INSERT INTO achievements (title, description, target, active, category, reward_gold, reward_money) VALUES
('첫 승리', '전투에서 1번 승리하세요', 1, true, 'battle', 5000, 0),
('전투 입문자', '전투에서 10번 승리하세요', 10, true, 'battle', 20000, 5),
('전투 고수', '전투에서 50번 승리하세요', 50, true, 'battle', 100000, 30),
('전투 마스터', '전투에서 100번 승리하세요', 100, true, 'battle', 300000, 100),
('무적의 전사', '전투에서 500번 승리하세요', 500, true, 'battle', 1000000, 300);

-- 룰렛 관련 업적
INSERT INTO achievements (title, description, target, active, category, reward_gold, reward_money) VALUES
('행운의 시작', '룰렛에서 1번 승리하세요', 1, true, 'roulette', 5000, 0),
('도박꾼', '룰렛에서 10번 승리하세요', 10, true, 'roulette', 30000, 10),
('행운아', '룰렛에서 50번 승리하세요', 50, true, 'roulette', 150000, 50),
('카지노 왕', '룰렛에서 100번 승리하세요', 100, true, 'roulette', 500000, 150);

-- ============================================
-- 마일스톤 보상 데이터 삽입
-- ============================================

INSERT INTO achievement_milestones (milestone_count, reward_gold, reward_money, reward_description) VALUES
(5, 50000, 10, '업적 5개 달성 보상'),
(10, 150000, 30, '업적 10개 달성 보상'),
(15, 300000, 75, '업적 15개 달성 보상'),
(20, 600000, 150, '업적 20개 달성 보상'),
(25, 1000000, 300, '업적 25개 달성 보상'),
(30, 2000000, 500, '업적 30개 달성 보상');

-- ============================================
-- 트리거: updated_at 자동 업데이트
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_achievements_updated_at ON user_achievements;
CREATE TRIGGER update_user_achievements_updated_at
    BEFORE UPDATE ON user_achievements
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
