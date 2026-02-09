-- 히든검 영속성을 위한 DB 스키마 수정
-- user_swords 테이블에 is_hidden 컬럼 추가 (이미 있다면 무시됨)

-- 1. user_swords 테이블에 is_hidden 컬럼 추가
ALTER TABLE user_swords 
ADD COLUMN IF NOT EXISTS is_hidden BOOLEAN DEFAULT FALSE;

-- 2. user_swords 테이블에 hidden_expires_at 컬럼 추가 (히든검 만료 시간)
ALTER TABLE user_swords 
ADD COLUMN IF NOT EXISTS hidden_expires_at TIMESTAMP WITH TIME ZONE;

-- 3. 인덱스 추가 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_user_swords_is_hidden ON user_swords(is_hidden);
CREATE INDEX IF NOT EXISTS idx_user_swords_hidden_expires ON user_swords(hidden_expires_at);

-- 4. 히든검 만료 체크 함수 (선택사항)
CREATE OR REPLACE FUNCTION check_hidden_sword_expiry()
RETURNS TRIGGER AS $$
BEGIN
    -- 히든검이 만료되었으면 일반 검으로 변경
    IF NEW.is_hidden = TRUE AND NEW.hidden_expires_at IS NOT NULL AND NEW.hidden_expires_at < NOW() THEN
        NEW.is_hidden = FALSE;
        NEW.hidden_expires_at = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. 트리거 생성 (선택사항)
DROP TRIGGER IF EXISTS trigger_check_hidden_expiry ON user_swords;
CREATE TRIGGER trigger_check_hidden_expiry
    BEFORE UPDATE ON user_swords
    FOR EACH ROW
    EXECUTE FUNCTION check_hidden_sword_expiry();

-- 6. 주석 추가
COMMENT ON COLUMN user_swords.is_hidden IS '히든검 여부 (TRUE: 히든검, FALSE: 일반검)';
COMMENT ON COLUMN user_swords.hidden_expires_at IS '히든검 만료 시간 (NULL이면 영구)';
