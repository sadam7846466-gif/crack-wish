-- Tüm istatistikleri tutmak için profiles tablosuna yeni kolonlar ekle
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_cookies INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_tarots INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_dreams INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS streak_days INTEGER DEFAULT 0;

-- YENİ EKLENENLER: Mektuplar, Arkadaş, Davet, Kurabiye Koleksiyonu ve Başarımlar
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_friends INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_letters_sent INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_referrals INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS unique_cookies INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS unlocked_achievements TEXT[] DEFAULT '{}';

-- Hızlı analiz ve sıralama yapabilmek için (leaderboard) indexler (İsteğe bağlı ama önerilir)
CREATE INDEX IF NOT EXISTS idx_profiles_total_cookies ON profiles (total_cookies DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_total_tarots ON profiles (total_tarots DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_streak_days ON profiles (streak_days DESC);
