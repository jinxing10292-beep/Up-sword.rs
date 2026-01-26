// Supabase Configuration
const SUPABASE_URL = 'https://glwpcuokjzfdwnsjhyuc.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdsd3BjdW9ranpmZHduc2poeXVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkzNTQwMzEsImV4cCI6MjA4NDkzMDAzMX0.LE9VJ18US_MSkkCOzmNCxeRpJbEkpCGSlXp3wOTyAnA'; // TODO: Add your anon key here

// Create Supabase client
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
