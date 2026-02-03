-- 전체 데이터베이스 스키마 완성 SQL
-- 모든 누락된 컬럼과 테이블을 추가합니다

-- ========================================
-- 1. PROFILES 테이블 컬럼 추가
-- ========================================
DO $$ 
BEGIN
    -- 배틀 시스템 컬럼
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='battle_exp') THEN
        ALTER TABLE profiles ADD COLUMN battle_exp INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='battle_level') THEN
        ALTER TABLE profiles ADD COLUMN battle_level INTEGER DEFAULT 1;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='battle_coins') THEN
        ALTER TABLE profiles ADD COLUMN battle_coins INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='highest_dummy_defeated') THEN
        ALTER TABLE profiles ADD COLUMN highest_dummy_defeated INTEGER DEFAULT 0;
    END IF;
    
    -- 매크로 소유 여부
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='has_macro') THEN
        ALTER TABLE profiles ADD COLUMN has_macro BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- ========================================
-- 2. USER_SWORDS 테이블 컬럼 추가
-- ========================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='user_swords' AND column_name='created_at') THEN
        ALTER TABLE user_swords ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        -- 기존 데이터에 현재 시간 설정
        UPDATE user_swords SET created_at = NOW() WHERE created_at IS NULL;
    END IF;
END $$;

-- ========================================
-- 3. USER_ITEMS 테이블 생성
-- ========================================
CREATE TABLE IF NOT EXISTS user_items (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_id TEXT NOT NULL,
    item_name TEXT NOT NULL,
    item_type TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- 4. BATTLE_HISTORY 테이블 생성
-- ========================================
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

-- ========================================
-- 5. 인덱스 생성
-- ========================================
CREATE INDEX IF NOT EXISTS idx_user_swords_user_id ON user_swords(user_id);
CREATE INDEX IF NOT EXISTS idx_user_swords_created_at ON user_swords(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_items_user_id ON user_items(user_id);
CREATE INDEX IF NOT EXISTS idx_user_items_item_id ON user_items(item_id);

CREATE INDEX IF NOT EXISTS idx_battle_history_user_id ON battle_history(user_id);
CREATE INDEX IF NOT EXISTS idx_battle_history_created_at ON battle_history(created_at DESC);

-- ========================================
-- 6. RLS 정책 설정
-- ========================================

-- USER_SWORDS 테이블
ALTER TABLE user_swords ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can insert own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can delete own swords" ON user_swords;

CREATE POLICY "Users can view own swords"
ON user_swords FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own swords"
ON user_swords FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own swords"
ON user_swords FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- USER_ITEMS 테이블
ALTER TABLE user_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own items" ON user_items;
DROP POLICY IF EXISTS "Users can insert own items" ON user_items;
DROP POLICY IF EXISTS "Users can update own items" ON user_items;
DROP POLICY IF EXISTS "Users can delete own items" ON user_items;

CREATE POLICY "Users can view own items"
ON user_items FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own items"
ON user_items FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items"
ON user_items FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own items"
ON user_items FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- BATTLE_HISTORY 테이블
ALTER TABLE battle_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own battle history" ON battle_history;
DROP POLICY IF EXISTS "Users can insert own battle history" ON battle_history;

CREATE POLICY "Users can view own battle history"
ON battle_history FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own battle history"
ON battle_history FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- PROFILES 테이블
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- ========================================
-- 7. 확인 쿼리
-- ========================================

-- profiles 테이블 컬럼 확인
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'profiles' 
AND column_name IN ('battle_exp', 'battle_level', 'battle_coins', 'highest_dummy_defeated', 'has_macro')
ORDER BY column_name;

-- user_swords 테이블 컬럼 확인
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'user_swords'
ORDER BY ordinal_position;

-- 모든 RLS 정책 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename IN ('profiles', 'user_swords', 'user_items', 'battle_history')
ORDER BY tablename, policyname;
