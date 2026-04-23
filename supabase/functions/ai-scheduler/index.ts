import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"
import admin from "npm:firebase-admin@11.11.1"

const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}');

if (!admin.apps.length && Object.keys(serviceAccount).length > 0) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    // AI Karar Motoru: En az 1 gündür aktif olmayanları bul (Spam yapmamak için 24 saat kuralı)
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    
    // Son 1 haftada aktif olmuş ama son 24 saatte girmemiş olanlara "Gel" diyeceğiz
    const oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

    const { data: profiles, error } = await supabase
      .from('profiles')
      .select('id, fcm_token, last_active_at, birth_date, zodiac_sign')
      .not('fcm_token', 'is', null)
      // .lt('last_active_at', twentyFourHoursAgo) // Not: TEST İÇİN ŞU AN BU KURALI KAPATIYORUZ!
      // .gt('last_active_at', oneWeekAgo);

    if (error || !profiles) {
      return new Response(JSON.stringify({ error: error?.message }), { status: 400 });
    }

    const messages = [];

    // Her kullanıcı için ayrı analiz yap
    for (const profile of profiles) {
      if (!profile.fcm_token) continue;

      let title = "";
      let body = "";

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
        title = "Doğum Günün Kutlu Olsun! 🎂";
        body = "Bugün senin günün. Evrenin sana özel bir mesajı ve hediyesi var, hemen içeri gel!";
      } else {
        // 2. Rastgele AI İçerik Seçimi (Tarot, Rüya, Fal)
        const randomChoice = Math.random();
        
        if (randomChoice < 0.33) {
          title = "Tarot Kartların Hazır 🃏";
          body = "Gelecek senin için şekilleniyor. Niyetini tut ve bugünün rehber kartlarını çek.";
        } else if (randomChoice < 0.66) {
          title = "Rüyalarının Fısıltısı 🌙";
          body = "Dün gece zihnin sana ne anlatmaya çalıştı? Kozmik baykuş rüyanı yorumlamak için bekliyor.";
        } else {
          title = "Gökyüzü Hareketli ✨";
          body = profile.zodiac_sign 
              ? `Gökyüzünde hareketlilik var! Bir ${profile.zodiac_sign} olarak bugünkü şansını keşfet.`
              : "Yıldızlar bugün senin için parlıyor. Kozmik enerjini toplamayı unutma!";
        }
      }

      messages.push({
        token: profile.fcm_token,
        notification: { title, body },
        data: { type: "ai_schedule" },
      });
    }

    if (messages.length > 0) {
      // Toplu Gönderim
      const batchResponse = await admin.messaging().sendAll(messages);
      return new Response(JSON.stringify({ success: true, sentCount: batchResponse.successCount }), { headers: { "Content-Type": "application/json" } });
    } else {
      return new Response(JSON.stringify({ success: true, message: "No notifications to send." }), { headers: { "Content-Type": "application/json" } });
    }

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 });
  }
})
