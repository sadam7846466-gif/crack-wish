-- Elite (Premium) durumunu takip etmek için profiles tablosuna kolonlar ekle
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_elite BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS elite_since TIMESTAMPTZ;

-- Elite kullanıcıları hızlı sorgulamak için index
CREATE INDEX IF NOT EXISTS idx_profiles_is_elite ON profiles (is_elite) WHERE is_elite = TRUE;

-- Elite kullanıcıları görmek için Supabase panelinde kullanabilirsin:
-- SELECT full_name, handle, is_elite, elite_since, aura_points, soul_stones 
-- FROM profiles 
-- WHERE is_elite = TRUE
-- ORDER BY elite_since DESC;
