-- ============================================
-- User Items Table - 사용자 아이템 인벤토리
-- ============================================

-- user_items 테이블 생성
CREATE TABLE IF NOT EXISTS user_items (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_id TEXT NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    item_type TEXT NOT NULL DEFAULT 'enhancement',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_items_user_id ON user_items(user_id);
CREATE INDEX IF NOT EXISTS idx_user_items_item_id ON user_items(user_id, item_id);
CREATE INDEX IF NOT EXISTS idx_user_items_type ON user_items(user_id, item_type);

-- RLS (Row Level Security) 정책 설정
ALTER TABLE user_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own items"
    ON user_items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own items"
    ON user_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own items"
    ON user_items FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own items"
    ON user_items FOR DELETE
    USING (auth.uid() = user_id);

-- updated_at 트리거
DROP TRIGGER IF EXISTS update_user_items_updated_at ON user_items;
CREATE TRIGGER update_user_items_updated_at
    BEFORE UPDATE ON user_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 완료! Supabase SQL Editor에서 실행하세요.
-- ============================================