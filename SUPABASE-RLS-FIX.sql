-- 미니게임 골드 저장 문제 해결을 위한 RLS 정책

-- 1. 현재 RLS 상태 확인
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'profiles';

-- 2. profiles 테이블의 기존 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'profiles';

-- 3. 사용자가 자신의 프로필을 업데이트할 수 있도록 정책 추가
-- (이미 있다면 삭제 후 재생성)

-- 기존 정책 삭제 (있다면)
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON profiles;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON profiles;

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

-- 4. RLS가 비활성화되어 있다면 활성화
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 5. 확인: 정책이 제대로 생성되었는지 체크
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
WHERE tablename = 'profiles';
