-- 배틀 시스템 테이블 생성 SQL

-- 1. profiles 테이블에 배틀 관련 컬럼 추가
-- 먼저 컬럼이 존재하는지 확인하고 없으면 추가
DO $$ 
BEGIN
    -- battle_exp 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='battle_exp') THEN
        ALTER TABLE profiles ADD COLUMN battle_exp INTEGER DEFAULT 0;
    END IF;
    
    -- battle_level 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='battle_level') THEN
        ALTER TABLE profiles ADD COLUMN battle_level INTEGER DEFAULT 1;
    END IF;
    
    -- battle_coins 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='battle_coins') THEN
        ALTER TABLE profiles ADD COLUMN battle_coins INTEGER DEFAULT 0;
    END IF;
    
    -- highest_dummy_defeated 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='highest_dummy_defeated') THEN
        ALTER TABLE profiles ADD COLUMN highest_dummy_defeated INTEGER DEFAULT 0;
    END IF;
END $$;

-- 2. 배틀 기록 테이블 생성
CREATE TABLE IF NOT EXISTS battle_history (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    dummy_level INTEGER NOT NULL,
    user_sword_level INTEGER NOT NULL,
    user_attack INTEGER NOT NULL,
    dummy_hp INTEGER NOT NULL,
    result TEXT NOT NULL CHECK (result IN ('win', 'lose')),
    exp_gained INTEGER DEFAULT 0,
    coins_gained INTEGER DEFAULT 0,
    battle_log JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_battle_history_user_id ON battle_history(user_id);
CREATE INDEX IF NOT EXISTS idx_battle_history_created_at ON battle_history(created_at DESC);

-- 4. RLS 정책 설정
ALTER TABLE battle_history ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제
DROP POLICY IF EXISTS "Users can view own battle history" ON battle_history;
DROP POLICY IF EXISTS "Users can insert own battle history" ON battle_history;

-- 새 정책 생성
CREATE POLICY "Users can view own battle history"
ON battle_history FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own battle history"
ON battle_history FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 5. 확인
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'profiles' 
AND column_name IN ('battle_exp', 'battle_level', 'battle_coins', 'highest_dummy_defeated');

SELECT * FROM pg_policies WHERE tablename = 'battle_history';
