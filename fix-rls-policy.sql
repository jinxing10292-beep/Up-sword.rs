-- ============================================
-- Fix RLS Policy for Profiles Table
-- ============================================
-- 이 스크립트는 기존 테이블의 RLS 정책만 수정합니다.

-- 기존 정책 삭제
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view all profiles for ranking" ON profiles;

-- 새로운 정책 생성 (모든 사용자가 모든 프로필 조회 가능)
CREATE POLICY "Users can view all profiles" ON profiles
    FOR SELECT USING (true);
