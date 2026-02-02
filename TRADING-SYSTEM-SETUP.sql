-- ============================================
-- 트레이딩 시스템 확장 (주식, 귀금속, 명품)
-- Supabase SQL Editor에서 실행하세요
-- ============================================

-- 1. 거래 가능한 자산 테이블
CREATE TABLE IF NOT EXISTS tradable_assets (
    id SERIAL PRIMARY KEY,
    symbol TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL, -- 'stock', 'precious_metal', 'luxury'
    current_price DECIMAL(15,2) DEFAULT 1000,
    base_price DECIMAL(15,2) DEFAULT 1000,
    volatility DECIMAL(5,4) DEFAULT 0.02,
    trend_factor DECIMAL(5,4) DEFAULT 0,
    pieces_per_unit INTEGER DEFAULT 1, -- 1000 for metals, 1000000 for luxury
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 사용자 포트폴리오 테이블
CREATE TABLE IF NOT EXISTS user_portfolios (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    asset_symbol TEXT REFERENCES tradable_assets(symbol) ON DELETE CASCADE,
    pieces_owned BIGINT DEFAULT 0,
    avg_buy_price DECIMAL(15,2) DEFAULT 0,
    total_invested DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, asset_symbol)
);

-- 3. 거래 기록 테이블
CREATE TABLE IF NOT EXISTS trading_history (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    asset_symbol TEXT REFERENCES tradable_assets(symbol) ON DELETE CASCADE,
    trade_type TEXT NOT NULL, -- 'buy', 'sell'
    pieces INTEGER NOT NULL,
    price_per_piece DECIMAL(15,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 가격 히스토리 테이블
CREATE TABLE IF NOT EXISTS price_history (
    id SERIAL PRIMARY KEY,
    asset_symbol TEXT REFERENCES tradable_assets(symbol) ON DELETE CASCADE,
    price DECIMAL(15,2) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 뉴스/이벤트 테이블
CREATE TABLE IF NOT EXISTS market_news (
    id SERIAL PRIMARY KEY,
    asset_symbol TEXT REFERENCES tradable_assets(symbol) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT,
    impact_type TEXT NOT NULL, -- 'positive', 'negative', 'neutral'
    impact_strength DECIMAL(5,4) DEFAULT 0.01,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 기본 자산 데이터 삽입
-- ============================================

-- 주식 회사들
INSERT INTO tradable_assets (symbol, name, category, current_price, base_price, volatility, pieces_per_unit) VALUES
('SWORD', 'SWORD Inc.', 'stock', 1000, 1000, 0.025, 1),
('TECH', 'TechNova Corp', 'stock', 850, 850, 0.030, 1),
('ENERGY', 'GreenEnergy Ltd', 'stock', 1200, 1200, 0.035, 1),
('PHARMA', 'MediCore Pharma', 'stock', 2500, 2500, 0.040, 1),
('FINANCE', 'CryptoBank Group', 'stock', 750, 750, 0.045, 1),
('RETAIL', 'MegaMart Chain', 'stock', 450, 450, 0.020, 1)
ON CONFLICT (symbol) DO UPDATE SET
    name = EXCLUDED.name,
    current_price = EXCLUDED.current_price,
    base_price = EXCLUDED.base_price;

-- 귀금속 (1000피스 = 1g)
INSERT INTO tradable_assets (symbol, name, category, current_price, base_price, volatility, pieces_per_unit) VALUES
('GOLD', '금 (Gold)', 'precious_metal', 80, 80, 0.015, 1000),
('SILVER', '은 (Silver)', 'precious_metal', 1.2, 1.2, 0.025, 1000),
('PLATINUM', '백금 (Platinum)', 'precious_metal', 35, 35, 0.020, 1000),
('PALLADIUM', '팔라듐 (Palladium)', 'precious_metal', 28, 28, 0.030, 1000)
ON CONFLICT (symbol) DO UPDATE SET
    name = EXCLUDED.name,
    current_price = EXCLUDED.current_price,
    base_price = EXCLUDED.base_price;

-- 명품 (1000000피스 = 1개)
INSERT INTO tradable_assets (symbol, name, category, current_price, base_price, volatility, pieces_per_unit) VALUES
('HERMES', '에르메스 버킨백', 'luxury', 0.015, 0.015, 0.010, 1000000),
('ROLEX', '롤렉스 데이토나', 'luxury', 0.025, 0.025, 0.012, 1000000),
('CHANEL', '샤넬 클래식백', 'luxury', 0.008, 0.008, 0.008, 1000000),
('LV', '루이비통 스피디', 'luxury', 0.003, 0.003, 0.006, 1000000)
ON CONFLICT (symbol) DO UPDATE SET
    name = EXCLUDED.name,
    current_price = EXCLUDED.current_price,
    base_price = EXCLUDED.base_price;

-- ============================================
-- RLS 정책 설정
-- ============================================

-- tradable_assets 테이블
ALTER TABLE tradable_assets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view tradable assets" ON tradable_assets FOR SELECT USING (true);

-- user_portfolios 테이블
ALTER TABLE user_portfolios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own portfolio" ON user_portfolios FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own portfolio" ON user_portfolios FOR ALL USING (auth.uid() = user_id);

-- trading_history 테이블
ALTER TABLE trading_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own trading history" ON trading_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own trading history" ON trading_history FOR INSERT WITH CHECK (auth.uid() = user_id);

-- price_history 테이블
ALTER TABLE price_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view price history" ON price_history FOR SELECT USING (true);

-- market_news 테이블
ALTER TABLE market_news ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view market news" ON market_news FOR SELECT USING (true);

-- ============================================
-- 인덱스 생성
-- ============================================

CREATE INDEX IF NOT EXISTS idx_user_portfolios_user_id ON user_portfolios(user_id);
CREATE INDEX IF NOT EXISTS idx_trading_history_user_id ON trading_history(user_id);
CREATE INDEX IF NOT EXISTS idx_trading_history_asset ON trading_history(asset_symbol);
CREATE INDEX IF NOT EXISTS idx_price_history_asset ON price_history(asset_symbol);
CREATE INDEX IF NOT EXISTS idx_price_history_timestamp ON price_history(timestamp DESC);

-- 완료!