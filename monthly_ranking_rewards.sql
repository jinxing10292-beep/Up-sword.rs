-- ============================================
-- 월간 랭킹 보상 시스템
-- ============================================

-- 1. monthly_ranking_rewards 테이블 (월간 랭킹 보상 기록)
CREATE TABLE IF NOT EXISTS monthly_ranking_rewards (
    id BIGSERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rank INTEGER NOT NULL,
    sword_level INTEGER NOT NULL,
    reward_money INTEGER NOT NULL,
    claimed BOOLEAN DEFAULT false,
    claimed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month, rank)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_monthly_ranking_rewards_user_id ON monthly_ranking_rewards(user_id);
CREATE INDEX IF NOT EXISTS idx_monthly_ranking_rewards_year_month ON monthly_ranking_rewards(year, month);

-- RLS 정책
ALTER TABLE monthly_ranking_rewards ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제 후 재생성
DROP POLICY IF EXISTS "Users can view all ranking rewards" ON monthly_ranking_rewards;
DROP POLICY IF EXISTS "Users can update their own rewards" ON monthly_ranking_rewards;

CREATE POLICY "Users can view all ranking rewards"
    ON monthly_ranking_rewards FOR SELECT
    USING (true);

CREATE POLICY "Users can update their own rewards"
    ON monthly_ranking_rewards FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- 월간 랭킹 1위 보상 지급 함수
-- ============================================

CREATE OR REPLACE FUNCTION award_monthly_ranking_rewards()
RETURNS void AS $$
DECLARE
    current_year INTEGER;
    current_month INTEGER;
    last_month INTEGER;
    last_year INTEGER;
    top_user RECORD;
BEGIN
    -- 현재 한국 시간 기준 (UTC+9)
    current_year := EXTRACT(YEAR FROM (NOW() AT TIME ZONE 'Asia/Seoul'));
    current_month := EXTRACT(MONTH FROM (NOW() AT TIME ZONE 'Asia/Seoul'));
    
    -- 지난 달 계산
    IF current_month = 1 THEN
        last_month := 12;
        last_year := current_year - 1;
    ELSE
        last_month := current_month - 1;
        last_year := current_year;
    END IF;
    
    -- 이미 지급된 보상이 있는지 확인
    IF EXISTS (
        SELECT 1 FROM monthly_ranking_rewards 
        WHERE year = last_year AND month = last_month AND rank = 1
    ) THEN
        RAISE NOTICE '이미 % 년 % 월 보상이 지급되었습니다.', last_year, last_month;
        RETURN;
    END IF;
    
    -- 지난 달 1위 유저 찾기 (검 레벨 기준)
    SELECT id, current_sword_lvl, COALESCE(nickname, username, email) as nickname
    INTO top_user
    FROM profiles
    WHERE current_sword_lvl IS NOT NULL
    ORDER BY current_sword_lvl DESC, updated_at ASC
    LIMIT 1;
    
    IF top_user.id IS NULL THEN
        RAISE NOTICE '랭킹 1위 유저를 찾을 수 없습니다.';
        RETURN;
    END IF;
    
    -- 보상 기록 생성
    INSERT INTO monthly_ranking_rewards (
        year, month, user_id, rank, sword_level, reward_money, claimed
    ) VALUES (
        last_year, last_month, top_user.id, 1, top_user.current_sword_lvl, 100, false
    );
    
    RAISE NOTICE '% 년 % 월 랭킹 1위 보상이 % 유저에게 지급 대기 중입니다.', 
        last_year, last_month, top_user.nickname;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 보상 수령 함수
-- ============================================

CREATE OR REPLACE FUNCTION claim_monthly_ranking_reward(reward_id BIGINT)
RETURNS JSONB AS $$
DECLARE
    reward_record RECORD;
    new_money INTEGER;
BEGIN
    -- 보상 정보 조회
    SELECT * INTO reward_record
    FROM monthly_ranking_rewards
    WHERE id = reward_id AND user_id = auth.uid();
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', '보상을 찾을 수 없습니다.');
    END IF;
    
    IF reward_record.claimed THEN
        RETURN jsonb_build_object('success', false, 'message', '이미 수령한 보상입니다.');
    END IF;
    
    -- 머니 지급
    UPDATE profiles
    SET money = COALESCE(money, 0) + reward_record.reward_money
    WHERE id = auth.uid()
    RETURNING money INTO new_money;
    
    -- 보상 수령 처리
    UPDATE monthly_ranking_rewards
    SET claimed = true, claimed_at = NOW()
    WHERE id = reward_id;
    
    RETURN jsonb_build_object(
        'success', true, 
        'message', '보상을 수령했습니다!',
        'reward_money', reward_record.reward_money,
        'new_money', new_money
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 매월 1일 자동 실행을 위한 cron 설정 (pg_cron 필요)
-- Supabase에서는 Edge Functions나 외부 스케줄러 사용 권장
-- ============================================

-- 수동 실행 예시:
-- SELECT award_monthly_ranking_rewards();

-- ============================================
-- 테스트 데이터 (개발용)
-- ============================================

-- 테스트: 지난 달 보상 생성
-- SELECT award_monthly_ranking_rewards();
