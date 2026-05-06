import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"
import admin from "npm:firebase-admin@11.11.1"

// Firebase Admin — push bildirim için
const firebaseServiceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}');
if (!admin.apps.length && Object.keys(firebaseServiceAccount).length > 0) {
  admin.initializeApp({
    credential: admin.credential.cert(firebaseServiceAccount)
  });
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ══════════════════════════════════════════════════════════════════
// SUNUCU TARAFLI ZAMANLANMIŞ BİLDİRİM MOTORU
// pg_cron ile saatte bir çağrılır, her kullanıcıya kişiselleştirilmiş
// bildirim gönderir.
// ══════════════════════════════════════════════════════════════════

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const now = new Date();
    const hour = now.getUTCHours() + 3; // UTC+3 (Türkiye)
    const adjustedHour = hour >= 24 ? hour - 24 : hour;
    const dayOfYear = Math.floor((now.getTime() - new Date(now.getFullYear(), 0, 0).getTime()) / 86400000);

    console.log(`⏰ Scheduled notification check — Saat: ${adjustedHour}:00 TR`);

    // FCM token'ı olan tüm kullanıcıları çek
    const { data: users, error } = await supabase
      .from('profiles')
      .select('id, fcm_token, zodiac_sign, display_name, last_active_at, is_premium, birth_date')
      .not('fcm_token', 'is', null)
      .neq('fcm_token', '');

    if (error || !users) {
      console.error('Profiles query error:', error);
      return new Response(JSON.stringify({ error: 'DB error' }), { status: 500, headers: corsHeaders });
    }

    console.log(`👥 ${users.length} kullanıcı FCM token'a sahip`);

    let sentCount = 0;
    let skipCount = 0;

    for (const user of users) {
      try {
        const { fcm_token, zodiac_sign, display_name, last_active_at, is_premium, birth_date } = user;
        const name = display_name || 'Ruh';
        const zodiac = zodiac_sign || 'Yıldıztozu';

        // Kullanıcı ne kadar süredir aktif değil?
        const lastActive = last_active_at ? new Date(last_active_at) : null;
        const hoursSinceActive = lastActive ? (now.getTime() - lastActive.getTime()) / 3600000 : 999;
        const daysSinceActive = hoursSinceActive / 24;

        // ─── KULLANICIYA ÖZEL SAAT OFSETİ ───
        // Her kullanıcı ID'sinden bir hash üretip, bildirimi farklı saate yayıyoruz.
        // Böylece 100K kullanıcı aynı anda bildirim almaz.
        const userHash = user.id.split('').reduce((acc: number, c: string) => acc + c.charCodeAt(0), 0);
        const userHourSlot = userHash % 12; // 0-11 arası bir slot (12 saate yay)
        // Kullanıcının "kendi bildirimi saati" = base saat + offset
        // Örnek: base 9 olan sabah bildirimi, userHourSlot=3 ise 12'de gider

        // Günde MAX 1 sunucu bildirimi gönder (saat kontrolü)
        let notification: { title: string; body: string } | null = null;

        // ═══════════════════════════════════════════════════
        // KATMAN 1: AKTİF KULLANICI (Son 24 saat)
        // ═══════════════════════════════════════════════════
        if (daysSinceActive < 1) {
          // Aktif kullanıcı — sadece kozmik olay varsa bildir
          // Her kullanıcı kendi slot saatinde alır (8-19 arası)
          const userNotifHour = 8 + (userHourSlot % 12);
          if (adjustedHour === userNotifHour) {
            const cosmicEvent = getCosmicEvent(now);
            if (cosmicEvent) {
              notification = {
                title: cosmicEvent.title,
                body: cosmicEvent.body.replace('{zodiac}', zodiac).replace('{name}', name),
              };
            }
          }
          // Doğum günü kontrolü
          if (adjustedHour === 10 && birth_date) {
            const bd = new Date(birth_date);
            if (bd.getMonth() === now.getMonth() && bd.getDate() === now.getDate()) {
              notification = {
                title: `🎂 Doğum günün kutlu olsun ${name}!`,
                body: 'Kozmik Baykuş sana özel bir doğum günü mektubu bıraktı 🦉✨',
              };
            }
          }
        }

        // ═══════════════════════════════════════════════════
        // KATMAN 2: HATIRLATICI (Son 24-48 saat)
        // ═══════════════════════════════════════════════════
        else if (daysSinceActive >= 1 && daysSinceActive < 2) {
          // Her kullanıcı 9-20 arası kendi slot saatinde alır
          const userNotifHour = 9 + (userHourSlot % 12);
          if (adjustedHour === userNotifHour) {
            const messages = [
              { title: `${name}, bugün kurabiyeni kırmayı unuttun 🥠`, body: `${zodiac} burcunun şans kurabiyesinde gizli bir mesaj var!` },
              { title: `Kartlar seninle konuşmak istiyor 🃏`, body: `${zodiac} burcuna özel tarot kartın hazır.` },
              { title: `Kozmik enerji yüksek! ✨`, body: `${name}, bugün ${zodiac} burcunun enerjisi dorukta.` },
            ];
            notification = messages[dayOfYear % messages.length];
          }
        }

        // ═══════════════════════════════════════════════════
        // KATMAN 3: GERİ KAZANIM (2-7 gün)
        // ═══════════════════════════════════════════════════
        else if (daysSinceActive >= 2 && daysSinceActive < 7) {
          // Her kullanıcı 10-21 arası kendi slot saatinde alır
          const userNotifHour = 10 + (userHourSlot % 12);
          if (adjustedHour === userNotifHour) {
            const messages = [
              { title: `Kozmik birikimin var ✨`, body: `${name}, ${zodiac} burcunun ${Math.floor(daysSinceActive)} günlük enerjisi birikti. Gel ve topla!` },
              { title: `Seni özledik ${name} 🦉`, body: `Baykuşun sana gizli bir sürpriz mektup bıraktı.` },
              { title: `${zodiac} burcunun bu hafta önemli! 🌟`, body: `${name}, kozmik rehberliğini kaçırma.` },
            ];
            notification = messages[Math.floor(daysSinceActive) % messages.length];
          }
        }

        // ═══════════════════════════════════════════════════
        // KATMAN 4: KRİTİK GERİ KAZANIM (7-30 gün)
        // ═══════════════════════════════════════════════════
        else if (daysSinceActive >= 7 && daysSinceActive < 30) {
          // Haftada 1 kez (her Pazartesi) bildir
          if (now.getDay() === 1 && adjustedHour === (9 + (userHourSlot % 10))) {
            const messages = [
              { title: `Önemli bir kozmik dönem 🌟`, body: `${zodiac} burcunun bu hafta çok özel bir döngüsü var. Bunu kaçırmamalısın!` },
              { title: `${name}, yıldızların hizalanıyor ✨`, body: `Uzun süredir girmedin ama evren seni beklemeye devam ediyor.` },
            ];
            notification = messages[dayOfYear % messages.length];
          }
        }

        // ═══════════════════════════════════════════════════
        // KATMAN 5: SON ÇAĞRI (30+ gün)
        // ═══════════════════════════════════════════════════
        else if (daysSinceActive >= 30) {
          // Ayda 1 kez (ayın 1'i)
          if (now.getDate() === 1 && adjustedHour === (10 + (userHourSlot % 8))) {
            notification = {
              title: `Kozmik enerjin zayıflıyor... 🔥`,
              body: `${name}, ${zodiac} burcunun mesajlarını okumayı bırakalı çok oldu. Evren hala seni bekliyor!`,
            };
          }
        }

        // Bildirim gönder
        if (notification && fcm_token) {
          try {
            await admin.messaging().send({
              token: fcm_token,
              notification: {
                title: notification.title,
                body: notification.body,
              },
              apns: {
                headers: { 'apns-priority': '10' },
                payload: {
                  aps: {
                    alert: { title: notification.title, body: notification.body },
                    sound: 'default',
                    badge: 1,
                    'content-available': 1,
                  },
                },
              },
              data: {
                type: 'scheduled_reminder',
              },
            });
            sentCount++;
            console.log(`✅ Gönderildi: ${name} (${zodiac})`);
          } catch (sendErr: any) {
            // Token geçersizse temizle
            if (sendErr?.code === 'messaging/registration-token-not-registered' ||
                sendErr?.code === 'messaging/invalid-registration-token') {
              await supabase.from('profiles').update({ fcm_token: null }).eq('id', user.id);
              console.log(`🗑️ Geçersiz token temizlendi: ${user.id}`);
            } else {
              console.error(`❌ Gönderilemedi (${name}):`, sendErr?.message || sendErr);
            }
          }
        } else {
          skipCount++;
        }
      } catch (userErr) {
        console.error('Kullanıcı işleme hatası:', userErr);
      }
    }

    const result = { sent: sentCount, skipped: skipCount, total: users.length, hour: adjustedHour };
    console.log(`📊 Sonuç:`, result);

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error('Scheduled notification error:', err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: corsHeaders,
    });
  }
});

// ══════════════════════════════════════════════════════════════════
// YARDIMCI: Bugün kozmik bir olay var mı?
// ══════════════════════════════════════════════════════════════════
function getCosmicEvent(date: Date): { title: string; body: string } | null {
  const key = `${date.getMonth() + 1}-${date.getDate()}`;
  const events: Record<string, { title: string; body: string }> = {
    // 2026 Dolunayları
    '1-13': { title: 'Dolunay Gecesi 🌕', body: '{zodiac} burcunda dolunay! Duygular yoğun.' },
    '2-12': { title: 'Dolunay Enerjisi 🌕', body: '{name}, dolunay gecesi rüyaların çok anlamlı!' },
    '3-14': { title: 'Dolunay Aydınlanması 🌕', body: '{zodiac} burcunu derinlemesine etkiliyor.' },
    '4-12': { title: 'Dolunay Gücü 🌕', body: '{name}, dolunay gecesi tarot kartın çok güçlü!' },
    '5-12': { title: 'Dolunay Sihri 🌕', body: '{zodiac} burcunun dolunay enerjisi dorukta!' },
    '6-11': { title: 'Dolunay Ritüeli 🌕', body: '{name}, kozmik enerjinle bağlan.' },
    '7-10': { title: 'Dolunay Farkındalığı 🌕', body: '{zodiac} dolunaydan güç alıyor!' },
    '8-8':  { title: 'Dolunay Dönüşümü 🌕', body: '{name}, içsel dönüşümün başlıyor.' },
    '9-7':  { title: 'Dolunay Hasadı 🌕', body: '{zodiac} hasat zamanı. Emeklerin karşılığı geliyor!' },
    '10-7': { title: 'Dolunay Dengesi 🌕', body: '{name}, bu dolunay denge getiriyor.' },
    '11-5': { title: 'Dolunay Derinliği 🌕', body: '{zodiac} için derin sezgiler.' },
    '12-4': { title: 'Dolunay Kapanışı 🌕', body: '{name}, yılın döngüsünü kapat.' },
    // 2026 Merkür Retroları
    '3-15': { title: 'Merkür Retrosu Başladı ☿️', body: '{zodiac} dikkat! İletişimde dikkatli ol.' },
    '4-7':  { title: 'Merkür Retrosu Bitti ✨', body: '{name}, iletişim yeniden akıyor!' },
    '7-18': { title: 'Merkür Retrosu Başladı ☿️', body: '{zodiac} yaz retrosuna hazır mısın?' },
    '8-11': { title: 'Merkür Retrosu Bitti ✨', body: '{name}, planlarını hayata geçir!' },
    '11-10': { title: 'Merkür Retrosu Başladı ☿️', body: '{zodiac} yıl sonunu sakin geçir.' },
    '12-1': { title: 'Merkür Retrosu Bitti ✨', body: '{name}, yılın son retrosu bitti!' },
  };
  return events[key] || null;
}
