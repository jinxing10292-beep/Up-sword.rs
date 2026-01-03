-- Create the battles table with all necessary fields
CREATE TABLE IF NOT EXISTS public.battles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player1_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    player2_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    player1_nickname TEXT NOT NULL,
    player2_nickname TEXT,
    status TEXT NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting', 'in_progress', 'completed', 'cancelled')),
    current_turn TEXT,
    winner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '5 minutes'),
    battle_data JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_battles_status ON public.battles(status);
CREATE INDEX IF NOT EXISTS idx_battles_player1_id ON public.battles(player1_id);
CREATE INDEX IF NOT EXISTS idx_battles_player2_id ON public.battles(player2_id);
CREATE INDEX IF NOT EXISTS idx_battles_created_at ON public.battles(created_at);
CREATE INDEX IF NOT EXISTS idx_battles_expires_at ON public.battles(expires_at) WHERE status = 'waiting';
CREATE INDEX IF NOT EXISTS idx_battles_winner_id ON public.battles(winner_id);
CREATE INDEX IF NOT EXISTS idx_battles_status_created ON public.battles(status, created_at);

-- Create RPC function to check if table exists
CREATE OR REPLACE FUNCTION public.check_battle_table_exists()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    table_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE  table_schema = 'public'
        AND    table_name   = 'battles'
    ) INTO table_exists;
    
    RETURN table_exists;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.check_battle_table_exists() TO authenticated;

-- Create a function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_battles_updated_at ON public.battles;
CREATE TRIGGER update_battles_updated_at
BEFORE UPDATE ON public.battles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Enable Row Level Security on battles table
ALTER TABLE public.battles ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to read their own battles
CREATE POLICY "사용자 본인의 배틀만 읽기"
ON public.battles
FOR SELECT
USING (auth.uid() = player1_id OR auth.uid() = player2_id);

-- Policy to allow users to update their own battles
CREATE POLICY "사용자 본인의 배틀만 업데이트"
ON public.battles
FOR UPDATE
USING (auth.uid() = player1_id OR auth.uid() = player2_id);

-- Policy to allow users to insert new battles
CREATE POLICY "사용자 배틀 생성 가능"
ON public.battles
FOR INSERT
WITH CHECK (auth.uid() = player1_id);

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.battles TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Add comments for documentation
COMMENT ON TABLE public.battles IS 'Stores information about battles between players';
COMMENT ON COLUMN public.battles.status IS 'Current status of the battle: waiting, in_progress, completed, cancelled';
COMMENT ON COLUMN public.battles.current_turn IS 'ID of the player whose turn it is';
COMMENT ON COLUMN public.battles.winner_id IS 'ID of the winning player, if the battle is completed';

-- Function to clean up expired battles
CREATE OR REPLACE FUNCTION public.cleanup_expired_battles()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.battles
    SET status = 'cancelled',
        updated_at = NOW()
    WHERE status = 'waiting'
    AND expires_at < NOW();
    
    RAISE NOTICE 'Cleaned up expired battles at %', NOW();
END;
$$;

-- Create a cron job to clean up expired battles every minute
SELECT cron.schedule(
    'cleanup-expired-battles',
    '* * * * *',
    'SELECT public.cleanup_expired_battles()'
);

-- Function to get active battles count
CREATE OR REPLACE FUNCTION public.get_user_active_battles_count(user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    battle_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO battle_count
    FROM public.battles
    WHERE (player1_id = user_id OR player2_id = user_id)
    AND status IN ('waiting', 'in_progress');
    
    RETURN battle_count;
END;
$$;

-- Enable pg_cron extension if not exists
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Grant usage to postgres role for pg_cron
GRANT USAGE ON SCHEMA cron TO postgres;

-- Notify that the setup is complete
NOTICE 'Battle system database setup completed successfully with all features';
