-- ============================================
-- Sword Enhancement System - Database Tables
-- ============================================

-- 1. user_swords 테이블 (사용자 인벤토리)
CREATE TABLE IF NOT EXISTS user_swords (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    sword_id INTEGER NOT NULL,
    sword_level INTEGER NOT NULL DEFAULT 0,
    sword_name TEXT NOT NULL,
    weapon_type TEXT NOT NULL DEFAULT 'normal',
    weapon_key TEXT,
    attack INTEGER DEFAULT 0,
    rarity TEXT DEFAULT 'common',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_swords_user_id ON user_swords(user_id);
CREATE INDEX IF NOT EXISTS idx_user_swords_sword_id ON user_swords(sword_id);
CREATE INDEX IF NOT EXISTS idx_user_swords_weapon_type ON user_swords(weapon_type);

-- 2. user_weapon_discoveries 테이블 (검 발견 기록)
CREATE TABLE IF NOT EXISTS user_weapon_discoveries (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    weapon_type TEXT NOT NULL,
    weapon_key TEXT NOT NULL,
    max_discovered_level INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, weapon_type, weapon_key)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_discoveries_user_id ON user_weapon_discoveries(user_id);
CREATE INDEX IF NOT EXISTS idx_discoveries_weapon ON user_weapon_discoveries(weapon_type, weapon_key);

-- 3. battles 테이블 (배틀 기록)
CREATE TABLE IF NOT EXISTS battles (
    id BIGSERIAL PRIMARY KEY,
    player1_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    player2_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    player1_sword_id BIGINT REFERENCES user_swords(id) ON DELETE SET NULL,
    player2_sword_id BIGINT REFERENCES user_swords(id) ON DELETE SET NULL,
    winner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    battle_log TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_battles_player1 ON battles(player1_id);
CREATE INDEX IF NOT EXISTS idx_battles_player2 ON battles(player2_id);
CREATE INDEX IF NOT EXISTS idx_battles_winner ON battles(winner_id);
CREATE INDEX IF NOT EXISTS idx_battles_created_at ON battles(created_at DESC);

-- 4. battle_logs 테이블 (배틀 상세 로그)
CREATE TABLE IF NOT EXISTS battle_logs (
    id BIGSERIAL PRIMARY KEY,
    battle_id BIGINT NOT NULL REFERENCES battles(id) ON DELETE CASCADE,
    step INTEGER NOT NULL,
    action TEXT NOT NULL,
    damage INTEGER DEFAULT 0,
    result TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_battle_logs_battle_id ON battle_logs(battle_id);
CREATE INDEX IF NOT EXISTS idx_battle_logs_step ON battle_logs(battle_id, step);

-- 5. sword_data 테이블 (검 레벨별 데이터 - 이미 있을 수 있음)
CREATE TABLE IF NOT EXISTS sword_data (
    id SERIAL PRIMARY KEY,
    level INTEGER NOT NULL UNIQUE,
    image_url TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 기본 검 데이터 삽입 (0~20레벨)
INSERT INTO sword_data (level, image_url, description) VALUES
(0, 'https://i.ibb.co/placeholder0.png', '기본 검'),
(1, 'https://i.ibb.co/placeholder1.png', '강화된 검 +1'),
(2, 'https://i.ibb.co/placeholder2.png', '강화된 검 +2'),
(3, 'https://i.ibb.co/placeholder3.png', '강화된 검 +3'),
(4, 'https://i.ibb.co/placeholder4.png', '강화된 검 +4'),
(5, 'https://i.ibb.co/placeholder5.png', '강화된 검 +5'),
(6, 'https://i.ibb.co/placeholder6.png', '강화된 검 +6'),
(7, 'https://i.ibb.co/placeholder7.png', '강화된 검 +7'),
(8, 'https://i.ibb.co/placeholder8.png', '강화된 검 +8'),
(9, 'https://i.ibb.co/placeholder9.png', '강화된 검 +9'),
(10, 'https://i.ibb.co/placeholder10.png', '강화된 검 +10'),
(11, 'https://i.ibb.co/placeholder11.png', '강화된 검 +11'),
(12, 'https://i.ibb.co/placeholder12.png', '강화된 검 +12'),
(13, 'https://i.ibb.co/placeholder13.png', '강화된 검 +13'),
(14, 'https://i.ibb.co/placeholder14.png', '강화된 검 +14'),
(15, 'https://i.ibb.co/placeholder15.png', '강화된 검 +15'),
(16, 'https://i.ibb.co/placeholder16.png', '강화된 검 +16'),
(17, 'https://i.ibb.co/placeholder17.png', '강화된 검 +17'),
(18, 'https://i.ibb.co/placeholder18.png', '강화된 검 +18'),
(19, 'https://i.ibb.co/placeholder19.png', '강화된 검 +19'),
(20, 'https://i.ibb.co/placeholder20.png', '강화된 검 +20')
ON CONFLICT (level) DO NOTHING;

-- 6. RLS (Row Level Security) 정책 설정

-- user_swords RLS
ALTER TABLE user_swords ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own swords"
    ON user_swords FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own swords"
    ON user_swords FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own swords"
    ON user_swords FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own swords"
    ON user_swords FOR DELETE
    USING (auth.uid() = user_id);

-- user_weapon_discoveries RLS
ALTER TABLE user_weapon_discoveries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own discoveries"
    ON user_weapon_discoveries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own discoveries"
    ON user_weapon_discoveries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own discoveries"
    ON user_weapon_discoveries FOR UPDATE
    USING (auth.uid() = user_id);

-- battles RLS
ALTER TABLE battles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own battles"
    ON battles FOR SELECT
    USING (auth.uid() = player1_id OR auth.uid() = player2_id);

CREATE POLICY "Users can create battles"
    ON battles FOR INSERT
    WITH CHECK (auth.uid() = player1_id);

-- battle_logs RLS
ALTER TABLE battle_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view battle logs for their battles"
    ON battle_logs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM battles
            WHERE battles.id = battle_logs.battle_id
            AND (battles.player1_id = auth.uid() OR battles.player2_id = auth.uid())
        )
    );

CREATE POLICY "Users can insert battle logs for their battles"
    ON battle_logs FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM battles
            WHERE battles.id = battle_logs.battle_id
            AND battles.player1_id = auth.uid()
        )
    );

-- sword_data는 모두가 읽을 수 있음
ALTER TABLE sword_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view sword data"
    ON sword_data FOR SELECT
    USING (true);

-- 7. 트리거 함수 (updated_at 자동 업데이트)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- user_swords 트리거
DROP TRIGGER IF EXISTS update_user_swords_updated_at ON user_swords;
CREATE TRIGGER update_user_swords_updated_at
    BEFORE UPDATE ON user_swords
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- user_weapon_discoveries 트리거
DROP TRIGGER IF EXISTS update_discoveries_updated_at ON user_weapon_discoveries;
CREATE TRIGGER update_discoveries_updated_at
    BEFORE UPDATE ON user_weapon_discoveries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 완료!
-- ============================================
-- 이제 Supabase SQL Editor에서 이 스크립트를 실행하세요.
-- 모든 테이블, 인덱스, RLS 정책이 생성됩니다.
