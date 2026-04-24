import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"
import admin from "npm:firebase-admin@11.11.1"

const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}');

if (!admin.apps.length && Object.keys(serviceAccount).length > 0) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

// ═══════════════════════════════════════════════════════════════
// 🍪 KURABİYE BİLDİRİMLERİ
// ═══════════════════════════════════════════════════════════════
const cookieNotifs = [
  { title: "Kurabiyenin İçinde Ne Var? 🍪", body: "Bugünkü şans mesajın hazır. Kır ve keşfet!" },
  { title: "Günlük Kurabiyeni Kırmadın 🍪", body: "Evren sana bir mesaj bıraktı ama sen hâlâ açmadın." },
  { title: "Taze Kurabiye Fırından Çıktı 🍪", body: "Bugünün şans kurabiyesi seni bekliyor. Kır ve oku!" },
  { title: "Kısmetin Kurabiyede 🍪", body: "Her kırılan kurabiyeden bir bilgelik doğar. Bugün ne çıkacak?" },
  { title: "Şansını Dene 🍪", body: "3 günlük kurabiye hakkın yenilendi. Hemen kır!" },
];

// ═══════════════════════════════════════════════════════════════
// 🃏 TAROT BİLDİRİMLERİ
// ═══════════════════════════════════════════════════════════════
const tarotNotifs = [
  { title: "Tarot Kartların Hazır 🃏", body: "Niyetini tut ve bugünün rehber kartlarını çek." },
  { title: "Kartlar Seni Çağırıyor 🃏", body: "Bugün evrenin senin için seçtiği 3 kartı görmek ister misin?" },
  { title: "Geleceğin Şekilleniyor 🃏", body: "Tarot masası kuruldu. Kartlarını çekmek için hazır mısın?" },
  { title: "Bugünün Rehberi 🃏", body: "Kararsız mısın? Bir tarot okuması zihnini aydınlatabilir." },
  { title: "Tarot Fısıldıyor 🃏", body: "Kartların sana vermek istediği mesaj var. Merak etmiyor musun?" },
];

// ═══════════════════════════════════════════════════════════════
// 🌙 RÜYA BİLDİRİMLERİ
// ═══════════════════════════════════════════════════════════════
const dreamNotifs = [
  { title: "Rüyalarının Fısıltısı 🌙", body: "Dün gece zihnin sana ne anlatmaya çalıştı? Rüyanı kaydet!" },
  { title: "Rüya Günlüğün Seni Bekliyor 🌙", body: "Uyanır uyanmaz rüyanı yaz — 10 dakika sonra %90'ı unutulur!" },
  { title: "Bilinçaltın Konuşuyor 🌙", body: "Dün geceki rüyan bir mesaj taşıyor olabilir. Analiz etmeye ne dersin?" },
  { title: "Rüyanda Ne Gördün? 🌙", body: "Kozmik baykuş rüyanı yorumlamak için bekliyor." },
  { title: "Zihnin Sana Bir Şey Söyledi 🌙", body: "Rüyalarında tekrar eden semboller var mı? Hemen kaydet ve keşfet." },
];

// ═══════════════════════════════════════════════════════════════
// ✨ BURÇ BİLDİRİMLERİ
// ═══════════════════════════════════════════════════════════════
const zodiacNotifs = [
  { title: "Gökyüzü Hareketli ✨", body: "Yıldızlar bugün senin için parlıyor. Burç yorumunu oku!" },
  { title: "Bugünkü Enerjin Ne? ✨", body: "Gökyüzündeki gezegenler sana ne fısıldıyor? Hemen öğren." },
  { title: "Kozmik Harita Güncellendi ✨", body: "Astroloji haritanda yeni hareketler var. Kontrol etmeye ne dersin?" },
  { title: "Yıldızların Rehberliği ✨", body: "Bugünün enerjisini doğru kullanmak için burç yorumuna göz at." },
  { title: "Gezegenlerin Dansı ✨", body: "Venüs ve Mars bugün sana ne söylüyor? Kozmik mesajını oku." },
];

// ═══════════════════════════════════════════════════════════════
// 🦉 MEKTUP / SOSYAL BİLDİRİMLER
// ═══════════════════════════════════════════════════════════════
const socialNotifs = [
  { title: "Baykuş Ağın Seni Özledi 🦉", body: "Arkadaşlarına bir mektup yollayalı uzun zaman oldu." },
  { title: "Kozmik Postacın Bekliyor 🦉", body: "Bir arkadaşına sürpriz bir mesaj göndermeye ne dersin?" },
  { title: "Bağlantılarını Güçlendir 🦉", body: "Baykuş ağındaki dostlarına bir selam gönder." },
];

// ═══════════════════════════════════════════════════════════════
// 🎂 DOĞUM GÜNÜ BİLDİRİMLERİ
// ═══════════════════════════════════════════════════════════════
const birthdayNotifs = [
  { title: "Doğum Günün Kutlu Olsun! 🎂", body: "Bugün senin günün. Evrenin sana özel bir mesajı ve hediyesi var!" },
  { title: "Yeni Yaşın Mübarek Olsun! 🎂", body: "Yıldızlar bugün senin için dans ediyor. Hediyeni almaya gel!" },
];

// ═══════════════════════════════════════════════════════════════
// 💎 GENEL HATIRLATICILAR (Streak, Aura, vb.)
// ═══════════════════════════════════════════════════════════════
const generalNotifs = [
  { title: "Serin Kırılmasın! 🔥", body: "Günlük giriş serini devam ettir. Bugün Aura puanını toplamayı unutma!" },
  { title: "Aura'n Birikirken ✨", body: "Günlük ritüellerini yaparak Aura puanını artır ve Ruh Taşına çevir." },
  { title: "Kozmik Yolculuğun Devam Ediyor 🚀", body: "Her gün biraz daha güçleniyorsun. Bugün de ritüellerini tamamla!" },
  { title: "Evren Seni Bekliyor 🌌", body: "Crack&Wish'te keşfedilecek çok şey var. Gel ve bugününü aydınlat!" },
];

// Rastgele seçici
function pickRandom<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Son 24 saatte girmemiş ama son 14 gün içinde aktif olmuş kullanıcıları bul
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const twoWeeksAgo = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString();

    // ⚠️ TEST MODU: Filtreler kapatıldı — yayından önce geri aç!
    const { data: profiles, error } = await supabase
      .from('profiles')
      .select('id, fcm_token, last_active_at, birth_date, zodiac_sign')
      .not('fcm_token', 'is', null);
      // .lt('last_active_at', twentyFourHoursAgo)  // TEST İÇİN KAPALI
      // .gt('last_active_at', twoWeeksAgo);         // TEST İÇİN KAPALI

    if (error || !profiles) {
      return new Response(JSON.stringify({ error: error?.message }), { status: 400 });
    }

    const messages = [];

    for (const profile of profiles) {
      if (!profile.fcm_token) continue;

      let notif = { title: "", body: "" };

      // 1. Doğum Günü Kontrolü (En Yüksek Öncelik)
      const today = new Date();
      let isBirthday = false;
      if (profile.birth_date) {
        const bDate = new Date(profile.birth_date);
        if (bDate.getDate() === today.getDate() && bDate.getMonth() === today.getMonth()) {
          isBirthday = true;
        }
      }

      if (isBirthday) {
        notif = pickRandom(birthdayNotifs);
      } else {
        // 2. Rastgele kategori seç (ağırlıklı)
        const roll = Math.random();

        if (roll < 0.20) {
          // %20 — Kurabiye
          notif = pickRandom(cookieNotifs);
        } else if (roll < 0.40) {
          // %20 — Tarot
          notif = pickRandom(tarotNotifs);
        } else if (roll < 0.55) {
          // %15 — Rüya
          notif = pickRandom(dreamNotifs);
        } else if (roll < 0.70) {
          // %15 — Burç (kişiselleştirilmiş)
          notif = pickRandom(zodiacNotifs);
          if (profile.zodiac_sign) {
            notif = { ...notif, body: notif.body.replace("senin için", `bir ${profile.zodiac_sign} olarak senin için`) };
          }
        } else if (roll < 0.80) {
          // %10 — Sosyal / Mektup
          notif = pickRandom(socialNotifs);
        } else {
          // %20 — Genel (Streak, Aura, Motivasyon)
          notif = pickRandom(generalNotifs);
        }
      }

      messages.push({
        token: profile.fcm_token,
        notification: { title: notif.title, body: notif.body },
        data: { type: "ai_schedule" },
      });
    }

    if (messages.length > 0) {
      const batchResponse = await admin.messaging().sendAll(messages);
      return new Response(JSON.stringify({ 
        success: true, 
        sentCount: batchResponse.successCount,
        totalTargeted: messages.length 
      }), { headers: { "Content-Type": "application/json" } });
    } else {
      return new Response(JSON.stringify({ success: true, message: "No inactive users to notify." }), { headers: { "Content-Type": "application/json" } });
    }

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 });
  }
})
