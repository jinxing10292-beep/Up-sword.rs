-- ============================================
-- 데이터베이스 오류 수정 SQL
-- Supabase SQL Editor에서 실행하세요
-- ============================================

-- 1. user_swords 테이블에 sword_id 컬럼 추가
ALTER TABLE user_swords ADD COLUMN IF NOT EXISTS sword_id INTEGER;

-- 2. monthly_ranking_rewards 테이블 생성
CREATE TABLE IF NOT EXISTS monthly_ranking_rewards (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    rank INTEGER NOT NULL,
    reward_gold BIGINT DEFAULT 0,
    reward_money BIGINT DEFAULT 0,
    month TEXT NOT NULL,
    claimed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. monthly_ranking_rewards RLS 설정
ALTER TABLE monthly_ranking_rewards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own rewards" ON monthly_ranking_rewards;
CREATE POLICY "Users can view own rewards" ON monthly_ranking_rewards
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own rewards" ON monthly_ranking_rewards;
CREATE POLICY "Users can update own rewards" ON monthly_ranking_rewards
    FOR UPDATE USING (auth.uid() = user_id);

-- 4. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_monthly_ranking_rewards_user_id ON monthly_ranking_rewards(user_id);
CREATE INDEX IF NOT EXISTS idx_monthly_ranking_rewards_claimed ON monthly_ranking_rewards(claimed);

-- 완료!
