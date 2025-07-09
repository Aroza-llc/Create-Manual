-- Fix cleanup_videos function to use extensions.http_post instead of net.http_post
CREATE OR REPLACE FUNCTION cleanup_videos()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  supabase_url text;
  anon_key text;
  full_url text;
  auth_header text;
BEGIN
  -- Get environment variables
  supabase_url := current_setting('app.settings.supabase_url', true);
  anon_key := current_setting('app.settings.supabase_anon_key', true);
  
  -- Fallback to default if not set
  IF supabase_url IS NULL THEN
    supabase_url := 'https://gltvuathwtbmrdjcqkqg.supabase.co';
  END IF;
  
  IF anon_key IS NULL THEN
    anon_key := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdsdHZ1YXRod3RibXJkamNxa3FnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1OTI5NzEsImV4cCI6MjA2NzE2ODk3MX0.YAPvDHmuCzIaiDaUqwThIIjzzOePIRnWBwFvo99JYWw';
  END IF;
  
  -- Construct the full URL and auth header
  full_url := supabase_url || '/functions/v1/cleanup-videos';
  auth_header := '{"Authorization": "Bearer ' || anon_key || '"}';
  
  -- Call the Edge Function using extensions.http_post
  PERFORM extensions.http_post(
    full_url,
    '{}',
    'application/json',
    auth_header
  );
END;
$$;