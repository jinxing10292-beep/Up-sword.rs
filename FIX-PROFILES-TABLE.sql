-- ============================================
-- profiles 테이블 수정 (current_weapon_type 컬럼 추가)
-- Supabase SQL Editor에서 실행하세요
-- ============================================

-- 1. current_weapon_type 컬럼 추가 (이미 있으면 무시됨)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS current_weapon_type TEXT DEFAULT 'normal';

-- 2. 기존 유저들의 current_weapon_type을 'normal'로 설정
UPDATE profiles SET current_weapon_type = 'normal' WHERE current_weapon_type IS NULL;

-- 3. 확인용 쿼리 (실행 후 결과 확인)
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name = 'current_weapon_type';

-- 완료!