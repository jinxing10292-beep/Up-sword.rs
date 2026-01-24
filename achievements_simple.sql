-- ============================================
-- 간단한 업적 시스템 설정
-- ============================================

-- 1. 필요한 컬럼 추가 (이미 있으면 무시됨)
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'general';
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS reward_gold INTEGER DEFAULT 0;
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS reward_money INTEGER DEFAULT 0;

-- 2. 기존 업적 삭제
DELETE FROM achievements WHERE title IN (
    '검의 시작', '초보 대장장이', '숙련된 대장장이', '마스터 대장장이', '전설의 대장장이',
    '강화 중독자', '강화 마니아', '강화의 신', '검 수집가', '검 박물관',
    '첫 재산', '부자의 시작', '백만장자', '억만장자', '골드 마스터',
    '머니의 시작', '머니 수집가', '머니 부자', '머니 재벌', '머니 황제',
    '첫 승리', '전투 입문자', '전투 고수', '전투 마스터', '무적의 전사',
    '행운의 시작', '도박꾼', '행운아', '카지노 왕'
);

-- 3. 현재 최대 id 찾기 및 새 업적 추가
DO $$
DECLARE
    next_id INTEGER;
BEGIN
    -- 현재 최대 id 찾기 (없으면 1000부터 시작)
    SELECT COALESCE(MAX(CAST(id AS INTEGER)), 999) + 1 INTO next_id 
    FROM achievements 
    WHERE id ~ '^[0-9]+$';  -- 숫자인 id만 선택
    
    -- 검 관련 업적
    INSERT INTO achievements (id, title, description, target, active, category, reward_gold, reward_money) VALUES
    (next_id, '검의 시작', '검을 +1 강화하세요', 1, true, 'sword', 1000, 0),
    (next_id + 1, '초보 대장장이', '검을 +5 강화하세요', 5, true, 'sword', 5000, 0),
    (next_id + 2, '숙련된 대장장이', '검을 +10 강화하세요', 10, true, 'sword', 20000, 5),
    (next_id + 3, '마스터 대장장이', '검을 +15 강화하세요', 15, true, 'sword', 100000, 20),
    (next_id + 4, '전설의 대장장이', '검을 +20 강화하세요', 20, true, 'sword', 500000, 100),
    (next_id + 5, '강화 중독자', '총 100번 강화하세요', 100, true, 'sword', 50000, 10),
    (next_id + 6, '강화 마니아', '총 500번 강화하세요', 500, true, 'sword', 200000, 50),
    (next_id + 7, '강화의 신', '총 1000번 강화하세요', 1000, true, 'sword', 1000000, 200),
    (next_id + 8, '검 수집가', '인벤토리에 검 10개를 보관하세요', 10, true, 'sword', 30000, 10),
    (next_id + 9, '검 박물관', '인벤토리에 검 50개를 보관하세요', 50, true, 'sword', 200000, 50);
    
    -- 골드 관련 업적
    INSERT INTO achievements (id, title, description, target, active, category, reward_gold, reward_money) VALUES
    (next_id + 10, '첫 재산', '골드 10,000G를 모으세요', 10000, true, 'gold', 5000, 0),
    (next_id + 11, '부자의 시작', '골드 100,000G를 모으세요', 100000, true, 'gold', 20000, 5),
    (next_id + 12, '백만장자', '골드 1,000,000G를 모으세요', 1000000, true, 'gold', 100000, 20),
    (next_id + 13, '억만장자', '골드 10,000,000G를 모으세요', 10000000, true, 'gold', 500000, 100),
    (next_id + 14, '골드 마스터', '골드 100,000,000G를 모으세요', 100000000, true, 'gold', 2000000, 500);
    
    -- 머니 관련 업적
    INSERT INTO achievements (id, title, description, target, active, category, reward_gold, reward_money) VALUES
    (next_id + 15, '머니의 시작', '머니 10M을 모으세요', 10, true, 'money', 10000, 5),
    (next_id + 16, '머니 수집가', '머니 100M을 모으세요', 100, true, 'money', 50000, 20),
    (next_id + 17, '머니 부자', '머니 1,000M을 모으세요', 1000, true, 'money', 200000, 100),
    (next_id + 18, '머니 재벌', '머니 10,000M을 모으세요', 10000, true, 'money', 1000000, 500),
    (next_id + 19, '머니 황제', '머니 100,000M을 모으세요', 100000, true, 'money', 5000000, 2000);
    
    -- 전투 관련 업적
    INSERT INTO achievements (id, title, description, target, active, category, reward_gold, reward_money) VALUES
    (next_id + 20, '첫 승리', '전투에서 1번 승리하세요', 1, true, 'battle', 5000, 0),
    (next_id + 21, '전투 입문자', '전투에서 10번 승리하세요', 10, true, 'battle', 20000, 5),
    (next_id + 22, '전투 고수', '전투에서 50번 승리하세요', 50, true, 'battle', 100000, 30),
    (next_id + 23, '전투 마스터', '전투에서 100번 승리하세요', 100, true, 'battle', 300000, 100),
    (next_id + 24, '무적의 전사', '전투에서 500번 승리하세요', 500, true, 'battle', 1000000, 300);
    
    -- 룰렛 관련 업적
    INSERT INTO achievements (id, title, description, target, active, category, reward_gold, reward_money) VALUES
    (next_id + 25, '행운의 시작', '룰렛에서 1번 승리하세요', 1, true, 'roulette', 5000, 0),
    (next_id + 26, '도박꾼', '룰렛에서 10번 승리하세요', 10, true, 'roulette', 30000, 10),
    (next_id + 27, '행운아', '룰렛에서 50번 승리하세요', 50, true, 'roulette', 150000, 50),
    (next_id + 28, '카지노 왕', '룰렛에서 100번 승리하세요', 100, true, 'roulette', 500000, 150);
    
    RAISE NOTICE '업적 % 개가 추가되었습니다. (ID: % ~ %)', 29, next_id, next_id + 28;
END $$;

-- 4. 마일스톤 테이블 생성 및 데이터
CREATE TABLE IF NOT EXISTS achievement_milestones (
    id BIGSERIAL PRIMARY KEY,
    milestone_count INTEGER NOT NULL UNIQUE,
    reward_gold INTEGER DEFAULT 0,
    reward_money INTEGER DEFAULT 0,
    reward_description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_achievement_milestones (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    milestone_id BIGINT NOT NULL REFERENCES achievement_milestones(id) ON DELETE CASCADE,
    claimed BOOLEAN DEFAULT false,
    claimed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, milestone_id)
);

-- 마일스톤 데이터 삽입 (중복 무시)
INSERT INTO achievement_milestones (milestone_count, reward_gold, reward_money, reward_description) 
VALUES 
(5, 50000, 10, '업적 5개 달성 보상'),
(10, 150000, 30, '업적 10개 달성 보상'),
(15, 300000, 75, '업적 15개 달성 보상'),
(20, 600000, 150, '업적 20개 달성 보상'),
(25, 1000000, 300, '업적 25개 달성 보상'),
(30, 2000000, 500, '업적 30개 달성 보상')
ON CONFLICT (milestone_count) DO NOTHING;

-- 5. RLS 정책 설정
ALTER TABLE achievement_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievement_milestones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view milestones" ON achievement_milestones;
CREATE POLICY "Anyone can view milestones" ON achievement_milestones FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can view their own milestone progress" ON user_achievement_milestones;
CREATE POLICY "Users can view their own milestone progress" ON user_achievement_milestones FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own milestone progress" ON user_achievement_milestones;
CREATE POLICY "Users can insert their own milestone progress" ON user_achievement_milestones FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own milestone progress" ON user_achievement_milestones;
CREATE POLICY "Users can update their own milestone progress" ON user_achievement_milestones FOR UPDATE USING (auth.uid() = user_id);
