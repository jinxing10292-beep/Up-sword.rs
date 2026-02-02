-- ============================================
-- Up Sword 게임 최종 데이터베이스 설정
-- Supabase SQL Editor에서 이 파일을 실행하세요
-- ============================================

-- 1. profiles 테이블에 current_weapon_type 컬럼 추가
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS current_weapon_type TEXT DEFAULT 'normal';

-- 2. 기존 유저 데이터 업데이트
UPDATE profiles SET current_weapon_type = 'normal' WHERE current_weapon_type IS NULL;

-- 3. profiles RLS 정책 수정 (모든 유저 조회 가능)
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Anyone can view all profiles" ON profiles;

CREATE POLICY "Anyone can view all profiles" ON profiles
    FOR SELECT USING (true);

-- 4. 검 데이터 삽입 (레벨 0-20)
INSERT INTO sword_data (level, name, price) VALUES
(0, '녹슨 검', 0),
(1, '낡은 검', 1000),
(2, '철 검', 2500),
(3, '강철 검', 5000),
(4, '은 검', 10000),
(5, '금 검', 20000),
(6, '다이아몬드 검', 40000),
(7, '에메랄드 검', 80000),
(8, '루비 검', 160000),
(9, '사파이어 검', 320000),
(10, '플래티넘 검', 640000),
(11, '미스릴 검', 1280000),
(12, '아다만타이트 검', 2560000),
(13, '오리하르콘 검', 5120000),
(14, '드래곤 검', 10240000),
(15, '전설의 검', 20480000),
(16, '신화의 검', 40960000),
(17, '불멸의 검', 81920000),
(18, '천상의 검', 163840000),
(19, '신성한 검', 327680000),
(20, '궁극의 검', 655360000)
ON CONFLICT (level) DO UPDATE SET name = EXCLUDED.name, price = EXCLUDED.price;

-- 5. 업적 데이터 삽입
INSERT INTO achievements (name, description, icon, condition_type, condition_value, reward_gold, reward_money, active) VALUES
('첫 강화', '검을 처음으로 강화하세요', '⚔️', 'enhance', 1, 1000, 0, true),
('강화 마스터', '검을 10번 강화하세요', '🗡️', 'enhance', 10, 10000, 100, true),
('강화의 신', '검을 50번 강화하세요', '⚡', 'enhance', 50, 50000, 500, true),
('강화 전설', '검을 100번 강화하세요', '💫', 'enhance', 100, 100000, 1000, true),
('첫 승리', '배틀에서 처음으로 승리하세요', '🏆', 'battle_win', 1, 2000, 0, true),
('전투의 달인', '배틀에서 10번 승리하세요', '🎖️', 'battle_win', 10, 20000, 200, true),
('무적의 전사', '배틀에서 50번 승리하세요', '👑', 'battle_win', 50, 100000, 1000, true),
('전쟁의 신', '배틀에서 100번 승리하세요', '⚡', 'battle_win', 100, 200000, 2000, true),
('룰렛 입문', '룰렛을 처음으로 플레이하세요', '🎰', 'roulette', 1, 500, 0, true),
('도박꾼', '룰렛을 20번 플레이하세요', '🎲', 'roulette', 20, 10000, 100, true),
('카지노 왕', '룰렛을 100번 플레이하세요', '🃏', 'roulette', 100, 50000, 500, true),
('부자', '골드 100만을 모으세요', '💰', 'gold', 1000000, 50000, 500, true),
('백만장자', '골드 1000만을 모으세요', '💎', 'gold', 10000000, 100000, 1000, true),
('억만장자', '골드 1억을 모으세요', '👑', 'gold', 100000000, 500000, 5000, true),
('검 수집가', '10개의 검을 수집하세요', '📦', 'sword_collect', 10, 30000, 300, true),
('검 마스터', '20개의 검을 수집하세요', '🎁', 'sword_collect', 20, 100000, 1000, true)
ON CONFLICT DO NOTHING;

-- 6. 업적 마일스톤 삽입
INSERT INTO achievement_milestones (milestone_count, reward_gold, reward_money) VALUES
(3, 5000, 50),
(5, 10000, 100),
(10, 25000, 250),
(15, 50000, 500),
(20, 100000, 1000),
(30, 200000, 2000),
(50, 500000, 5000)
ON CONFLICT (milestone_count) DO UPDATE SET reward_gold = EXCLUDED.reward_gold, reward_money = EXCLUDED.reward_money;

-- 7. 미션 데이터 삽입
INSERT INTO missions (title, description, mission_type, target_value, reward_gold, reward_money, active) VALUES
('일일 강화', '오늘 검을 5번 강화하세요', 'daily_enhance', 5, 5000, 50, true),
('일일 배틀', '오늘 배틀을 3번 하세요', 'daily_battle', 3, 3000, 30, true),
('일일 룰렛', '오늘 룰렛을 10번 하세요', 'daily_roulette', 10, 10000, 100, true),
('주간 강화왕', '이번 주에 검을 30번 강화하세요', 'weekly_enhance', 30, 30000, 300, true),
('주간 전투왕', '이번 주에 배틀을 20번 하세요', 'weekly_battle', 20, 20000, 200, true),
('주간 도박왕', '이번 주에 룰렛을 50번 하세요', 'weekly_roulette', 50, 50000, 500, true)
ON CONFLICT DO NOTHING;

-- 8. 상점 아이템 삽입
INSERT INTO shop_items (name, description, price_gold, price_money, item_type, active) VALUES
('확정 강화권', '다음 강화를 100% 성공시킵니다', 50000, 0, 'enhance_scroll', true),
('골드 부스터 (1시간)', '1시간 동안 골드 획득량 2배', 0, 100, 'gold_booster', true),
('경험치 부스터 (1시간)', '1시간 동안 경험치 획득량 2배', 0, 100, 'exp_booster', true),
('럭키 코인', '룰렛 당첨 확률 증가 (1회)', 100000, 0, 'lucky_coin', true),
('보호 주문서', '강화 실패 시 검 파괴 방지 (1회)', 200000, 0, 'protection_scroll', true),
('골드 팩 (소)', '골드 10만 획득', 0, 50, 'gold_pack_small', true),
('골드 팩 (중)', '골드 50만 획득', 0, 200, 'gold_pack_medium', true),
('골드 팩 (대)', '골드 100만 획득', 0, 350, 'gold_pack_large', true)
ON CONFLICT DO NOTHING;

-- 9. 샘플 보상 코드 삽입
INSERT INTO reward_codes (code, reward_gold, reward_money, active) VALUES
('WELCOME2024', 50000, 100, true),
('NEWUSER', 10000, 0, true),
('GRANDOPEN', 100000, 500, true)
ON CONFLICT (code) DO UPDATE SET reward_gold = EXCLUDED.reward_gold, reward_money = EXCLUDED.reward_money, active = EXCLUDED.active;

-- ============================================
-- 완료!
-- ============================================

-- 이제 다음을 확인하세요:
-- ✅ current_weapon_type 컬럼 추가
-- ✅ RLS 정책 수정 (모든 유저 조회 가능)
-- ✅ 검 데이터 21개 추가
-- ✅ 업적 16개 추가
-- ✅ 업적 마일스톤 7개 추가
-- ✅ 미션 6개 추가
-- ✅ 상점 아이템 8개 추가
-- ✅ 보상 코드 3개 추가

-- 주의사항:
-- 1. Supabase Dashboard > Authentication > Providers > Email에서
--    "Confirm email" 옵션을 비활성화하세요
-- 2. Storage에서 'codet-img' 버킷을 생성하세요 (Public: true)
