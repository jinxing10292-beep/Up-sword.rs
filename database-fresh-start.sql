-- ============================================
-- Up Sword 게임 완전 새로 시작 (Fresh Start)
-- 기존 테이블이 있으면 삭제하고 다시 생성
-- Supabase SQL Editor에서 실행하세요
-- ============================================

-- ============================================
-- 1단계: 기존 테이블 및 정책 삭제
-- ============================================

-- 정책 삭제
DROP POLICY IF EXISTS "Anyone can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view all profiles for ranking" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON