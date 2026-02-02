// Supabase Configuration
const SUPABASE_URL = 'https://blkghenrfizqjfigvkql.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJsa2doZW5yZml6cWpmaWd2a3FsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5NzM5MDksImV4cCI6MjA4NTU0OTkwOX0.L6oh-I5EKTyxkTtjzm95q-hBQaUwIq34RaE6UXV6gJg';

// Create Supabase client
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
