-- Create coffee_readings table
CREATE TABLE IF NOT EXISTS public.coffee_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    locale TEXT DEFAULT 'tr',
    status TEXT DEFAULT 'pending', -- pending, completed, failed
    result JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.coffee_readings ENABLE ROW LEVEL SECURITY;

-- Create Policies
CREATE POLICY "Users can view their own coffee readings"
ON public.coffee_readings FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own coffee readings"
ON public.coffee_readings FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own coffee readings"
ON public.coffee_readings FOR DELETE
USING (auth.uid() = user_id);


-- Create dream_readings table
CREATE TABLE IF NOT EXISTS public.dream_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    dream_text TEXT NOT NULL,
    locale TEXT DEFAULT 'tr',
    status TEXT DEFAULT 'pending', -- pending, completed, failed
    result JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.dream_readings ENABLE ROW LEVEL SECURITY;

-- Create Policies
CREATE POLICY "Users can view their own dream readings"
ON public.dream_readings FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own dream readings"
ON public.dream_readings FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own dream readings"
ON public.dream_readings FOR DELETE
USING (auth.uid() = user_id);
