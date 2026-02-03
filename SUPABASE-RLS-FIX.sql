-- 미니게임 골드 저장 문제 해결을 위한 RLS 정책

-- 1. 현재 RLS 상태 확인
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN ('profiles', 'user_swords', 'user_items', 'roulette_history');

-- 2. profiles 테이블의 기존 정책 확인
SELECT * FROM pg_policies WHERE tablename IN ('profiles', 'user_swords', 'user_items', 'roulette_history');

-- 3. 사용자가 자신의 프로필을 업데이트할 수 있도록 정책 추가

-- ===== PROFILES 테이블 =====
-- 기존 정책 삭제 (있다면)
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON profiles;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON profiles;

-- RLS 활성화
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 새로운 정책 생성
-- 1) 자신의 프로필 조회 가능
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- 2) 자신의 프로필 업데이트 가능 (골드, 머니 등)
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 3) 새 사용자 프로필 생성 가능
CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- ===== USER_SWORDS 테이블 =====
-- 기존 정책 삭제
DROP POLICY IF EXISTS "Users can view own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can insert own swords" ON user_swords;
DROP POLICY IF EXISTS "Users can delete own swords" ON user_swords;

-- RLS 활성화
ALTER TABLE user_swords ENABLE ROW LEVEL SECURITY;

-- 정책 생성
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

-- ===== USER_ITEMS 테이블 =====
-- 기존 정책 삭제
DROP POLICY IF EXISTS "Users can view own items" ON user_items;
DROP POLICY IF EXISTS "Users can insert own items" ON user_items;
DROP POLICY IF EXISTS "Users can update own items" ON user_items;
DROP POLICY IF EXISTS "Users can delete own items" ON user_items;

-- RLS 활성화
ALTER TABLE user_items ENABLE ROW LEVEL SECURITY;

-- 정책 생성
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

-- ===== ROULETTE_HISTORY 테이블 =====
-- 기존 정책 삭제
DROP POLICY IF EXISTS "Users can view own roulette history" ON roulette_history;
DROP POLICY IF EXISTS "Users can insert own roulette history" ON roulette_history;

-- RLS 활성화
ALTER TABLE roulette_history ENABLE ROW LEVEL SECURITY;

-- 정책 생성
CREATE POLICY "Users can view own roulette history"
ON roulette_history FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own roulette history"
ON roulette_history FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 4. 확인: 정책이 제대로 생성되었는지 체크
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('profiles', 'user_swords', 'user_items', 'roulette_history')
ORDER BY tablename, policyname;
