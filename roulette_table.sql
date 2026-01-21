-- ============================================
-- Roulette Game Table - 룰렛 게임 기록
-- ============================================

-- roulette_games 테이블 생성
CREATE TABLE IF NOT EXISTS roulette_games (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    winning_number INTEGER NOT NULL CHECK (winning_number >= 0 AND winning_number <= 36),
    total_bet_amount INTEGER NOT NULL DEFAULT 0,
    total_win_amount INTEGER NOT NULL DEFAULT 0,
    net_result INTEGER NOT NULL DEFAULT 0, -- 순손익 (win - bet)
    bets_placed JSONB, -- 베팅 정보 저장
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_roulette_games_user_id ON roulette_games(user_id);
CREATE INDEX IF NOT EXISTS idx_roulette_games_created_at ON roulette_games(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_roulette_games_net_result ON roulette_games(net_result DESC);

-- RLS (Row Level Security) 정책 설정
ALTER TABLE roulette_games ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own roulette games"
    ON roulette_games FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own roulette games"
    ON roulette_games FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 완료! Supabase SQL Editor에서 실행하세요.
-- ============================================