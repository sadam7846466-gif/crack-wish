BEGIN;
-- Enable Realtime for the new tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.coffee_readings;
ALTER PUBLICATION supabase_realtime ADD TABLE public.dream_readings;
COMMIT;
