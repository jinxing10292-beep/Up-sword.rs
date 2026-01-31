// Supabase Configuration
const SUPABASE_URL = 'https://tcixevutegeimzxmwabu.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjaXhldnV0ZWdlaW16eG13YWJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MzE0MjgsImV4cCI6MjA4NTQwNzQyOH0.-5Byh95HgE2yPM0m24LPEERZu6KJFe7eD0VSBGf_Ukk'; // 여기에 새 anon key를 넣으세요

// Create Supabase client
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
