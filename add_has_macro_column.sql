-- profiles 테이블에 has_macro 컬럼 추가
DO $$ 
BEGIN
    -- has_macro 컬럼이 없으면 추가
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'has_macro'
    ) THEN
        ALTER TABLE profiles ADD COLUMN has_macro BOOLEAN DEFAULT false;
        RAISE NOTICE 'has_macro 컬럼이 추가되었습니다.';
    ELSE
        RAISE NOTICE 'has_macro 컬럼이 이미 존재합니다.';
    END IF;
END $$;
