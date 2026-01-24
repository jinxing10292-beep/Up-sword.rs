-- ============================================
-- 유저 활동 로그 시스템
-- ============================================

-- 1. user_activity_logs 테이블 생성
CREATE TABLE IF NOT EXISTS user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL, -- 'sword_enhance', 'sword_sell', 'roulette_bet', 'battle', 'shop_purchase', 'daily_check', etc.
    action TEXT NOT NULL, -- 'gain', 'loss', 'neutral'
    gold_change BIGINT DEFAULT 0, -- 골드 변화량 (+ 또는 -)
    money_change BIGINT DEFAULT 0, -- 머니 변화량 (+ 또는 -)
    gold_before BIGINT DEFAULT 0, -- 활동 전 골드
    gold_after BIGINT DEFAULT 0, -- 활동 후 골드
    money_before BIGINT DEFAULT 0, -- 활동 전 머니
    money_after BIGINT DEFAULT 0, -- 활동 후 머니
    details JSONB, -- 추가 상세 정보 (검 레벨, 룰렛 번호, 배틀 상대 등)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_user_id ON user_activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_activity_type ON user_activity_logs(activity_type);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_created_at ON user_activity_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_user_created ON user_activity_logs(user_id, created_at DESC);

-- RLS 정책
ALTER TABLE user_activity_logs ENABLE ROW LEVEL SECURITY;

-- 유저는 자신의 로그만 볼 수 있음
DROP POLICY IF EXISTS "Users can view their own logs" ON user_activity_logs;
CREATE POLICY "Users can view their own logs"
    ON user_activity_logs FOR SELECT
    USING (auth.uid() = user_id);

-- 시스템(서버)에서만 로그 삽입 가능
DROP POLICY IF EXISTS "System can insert logs" ON user_activity_logs;
CREATE POLICY "System can insert logs"
    ON user_activity_logs FOR INSERT
    WITH CHECK (true);

-- ============================================
-- 로그 통계 조회 함수
-- ============================================

-- 유저별 활동 통계
CREATE OR REPLACE FUNCTION get_user_activity_stats(target_user_id UUID)
RETURNS TABLE (
    activity_type TEXT,
    total_count BIGINT,
    total_gold_gained BIGINT,
    total_gold_lost BIGINT,
    total_money_gained BIGINT,
    total_money_lost BIGINT,
    net_gold_change BIGINT,
    net_money_change BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.activity_type,
        COUNT(*)::BIGINT as total_count,
        SUM(CASE WHEN l.gold_change > 0 THEN l.gold_change ELSE 0 END)::BIGINT as total_gold_gained,
        SUM(CASE WHEN l.gold_change < 0 THEN ABS(l.gold_change) ELSE 0 END)::BIGINT as total_gold_lost,
        SUM(CASE WHEN l.money_change > 0 THEN l.money_change ELSE 0 END)::BIGINT as total_money_gained,
        SUM(CASE WHEN l.money_change < 0 THEN ABS(l.money_change) ELSE 0 END)::BIGINT as total_money_lost,
        SUM(l.gold_change)::BIGINT as net_gold_change,
        SUM(l.money_change)::BIGINT as net_money_change
    FROM user_activity_logs l
    WHERE l.user_id = target_user_id
    GROUP BY l.activity_type
    ORDER BY total_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 최근 활동 로그 조회
CREATE OR REPLACE FUNCTION get_recent_user_activities(target_user_id UUID, limit_count INTEGER DEFAULT 100)
RETURNS TABLE (
    id BIGINT,
    activity_type TEXT,
    action TEXT,
    gold_change BIGINT,
    money_change BIGINT,
    gold_before BIGINT,
    gold_after BIGINT,
    money_before BIGINT,
    money_after BIGINT,
    details JSONB,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.activity_type,
        l.action,
        l.gold_change,
        l.money_change,
        l.gold_before,
        l.gold_after,
        l.money_before,
        l.money_after,
        l.details,
        l.created_at
    FROM user_activity_logs l
    WHERE l.user_id = target_user_id
    ORDER BY l.created_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 활동 타입별 설명
-- ============================================

-- activity_type 값들:
-- 'sword_enhance_success' - 검 강화 성공
-- 'sword_enhance_fail' - 검 강화 실패 (레벨 유지)
-- 'sword_enhance_destroy' - 검 강화 실패 (파괴)
-- 'sword_sell' - 검 판매
-- 'sword_store' - 검 보관
-- 'roulette_win' - 룰렛 승리
-- 'roulette_lose' - 룰렛 패배
-- 'battle_win' - 배틀 승리
-- 'battle_lose' - 배틀 패배
-- 'shop_purchase' - 상점 구매
-- 'daily_check' - 출석 체크
-- 'mission_reward' - 미션 보상
-- 'achievement_reward' - 업적 보상
-- 'admin_adjust' - 관리자 조정
