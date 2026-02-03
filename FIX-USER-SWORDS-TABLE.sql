-- user_swords 테이블에 created_at 컬럼 추가

-- 1. created_at 컬럼 추가 (없는 경우에만)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='user_swords' AND column_name='created_at') THEN
        ALTER TABLE user_swords 
        ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        
        -- 기존 데이터에 현재 시간 설정
        UPDATE user_swords SET created_at = NOW() WHERE created_at IS NULL;
    END IF;
END $$;

-- 2. 인덱스 생성 (성능 향상)
CREATE INDEX IF NOT EXISTS idx_user_swords_created_at ON user_swords(created_at DESC);

-- 3. 확인
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'user_swords' 
AND column_name = 'created_at';
