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

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!;
const OPENAI_URL = "https://api.openai.com/v1/chat/completions";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { mode, images, locale, userId, record_id } = await req.json();
    const isTr = locale === "tr";

    // ═══════════════════════════════════════════════════════════════
    // MOD 1: FOTOĞRAF DOĞRULAMA (validate)
    // ═══════════════════════════════════════════════════════════════
    if (mode === "validate") {
      if (!images || images.length !== 4) {
        return new Response(
          JSON.stringify({ error: "4 images required" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const validationPrompt = `You are evaluating 4 images for a Turkish coffee reading app.

VALIDATION RULES (be LENIENT, not strict):
1. **Coffee Related?** Each image should be related to Turkish coffee fortune telling. Accept: coffee cups, saucers/plates with coffee residue, coffee grounds on plates, upside-down cups, etc. ONLY reject if the image is clearly NOT coffee-related (e.g. a selfie, a landscape, a random object with zero coffee connection).
2. **No Identical Photos:** FAIL only if the EXACT same photo file appears twice (same angle, same everything). Different angles of the same cup are FINE.
3. **Saucer/Plate Check:** At least one of the 4 images should show a saucer or plate. A saucer is the small flat plate that goes under a Turkish coffee cup — it usually has coffee residue/grounds on it. Be GENEROUS: if you see ANY flat circular dish with brown/dark residue, accept it as a saucer. Do NOT reject a valid coffee saucer just because it doesn't look like a "perfect plate".

IMPORTANT: When in doubt, ACCEPT the image. It is much worse to reject a valid coffee photo than to accept a slightly unclear one. Users are frustrated when valid photos get rejected.

If an image fails, provide a SHORT, friendly error message in ${isTr ? 'Turkish (use "sen" form)' : 'English'}.

Return ONLY valid JSON, no markdown. Format:
{
  "results": [
    {"valid": true, "error": null},
    {"valid": false, "error": "Bu alakasız bir fotoğraf..."},
    {"valid": true, "error": null},
    {"valid": true, "error": null}
  ]
}`;

      const imageContents = images.map((img: string, i: number) => ({
        type: "image_url",
        image_url: {
          url: `data:image/jpeg;base64,${img}`,
          detail: "low", // gpt-4o'da low detail kullanarak maliyeti çok düşük (85 token) tutuyoruz.
        },
      }));

      const response = await fetch(OPENAI_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model: "gpt-4o-mini", // KESİNLİKLE SADECE gpt-4o-mini KULLANILACAK
          messages: [
            { role: "system", content: validationPrompt },
            {
              role: "user",
              content: [
                { type: "text", text: "Please validate these 4 coffee cup photos using the 3-step checklist." },
                ...imageContents,
              ],
            },
          ],
          temperature: 0.1,
          max_tokens: 300,
          response_format: { type: "json_object" },
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        console.error("OpenAI validation error:", response.status, errText);
        // Fail-safe: doğrulama başarısız olursa hepsini geçerli say
        return new Response(
          JSON.stringify({
            results: [
              { valid: true, error: null },
              { valid: true, error: null },
              { valid: true, error: null },
              { valid: true, error: null },
            ],
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const data = await response.json();
      const rawContent = data.choices?.[0]?.message?.content;

      if (!rawContent) {
        // Fail-safe
        return new Response(
          JSON.stringify({
            results: [
              { valid: true, error: null },
              { valid: true, error: null },
              { valid: true, error: null },
              { valid: true, error: null },
            ],
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const parsed = JSON.parse(rawContent);
      return new Response(JSON.stringify(parsed), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // ═══════════════════════════════════════════════════════════════
    // MOD 2: KAHVE FALI YORUMU (interpret)
    // ═══════════════════════════════════════════════════════════════
    if (mode === "interpret") {
      if (!images || images.length !== 4) {
        return new Response(
          JSON.stringify({ error: "4 images required" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const systemPrompt = `Sen yıllardır kahve falı bakan, deneyimli ve sezgileri güçlü bir Türk falcısısın. Karşında oturan kişinin fincanına ve tabağına bakıyorsun.

SEN BİR FALCISIN, FİLOZOF DEĞİL! Kurallar:

1. **GÖRDÜĞÜNÜ SÖYLE:** Fincanda ve tabakta GERÇEKTEN gördüğün şekilleri isimleriyle say. Örnek: "Fincanın sağ kenarında bir kuş şekli var", "Dipte büyük koyu bir leke görüyorum", "Tabakta ince bir yol açılmış". Genel genel konuşma, NE GÖRDÜĞÜNÜ NET SÖYLE.

2. **NET TAHMİNLER YAP:** Lafı dolandırma. "Yakında güzel bir haber alacaksın", "Seni kıskanan biri var etrafında", "Maddi bir kazanç kapıda", "Bir yolculuk çıkacak karşına" gibi NET ve CESUR tahminlerde bulun. Gerçek falcılar belirsiz konuşmaz.

3. **SPESIFIK OL:** Her bölümde fincanın/tabağın hangi kısmına baktığını belirt. "Sol kenarda...", "Sağ tarafta...", "Fincanın dibinde...", "Tabağın ortasında..." gibi.

4. **ŞEKİLLERİ YORUMLA (EZBERE KONUŞMA):** Kuş, kalp, yılan gibi klasik sembollere takılıp kalma. Fincanın BİÇİMİNE, dokusuna, lekelerin dağılımına odaklan. Her fala aynı sembolleri yazarsan gerçekçiliğin kaybolur. O fincandaki BENZERSİZ lekeleri, çizgileri ve boşlukları yorumla.

5. **HİSSETTİR:** Kişi falı okuduktan sonra "Vay be, gerçekten baktı fincanıma" demeli. JENERİK VE KLİŞE, HER FİNCAN İÇİN GEÇERLİ OLAN CÜMLELER (ör. "geçmişin yüklerinden kurtul", "önünde aydınlık bir yol var") YAZMA. Fincanın kendine özgü, spesifik hikayesini anlat.

6. **DİL:** ${isTr ? 'Türkçe yaz. "Sen" diye hitap et. Samimi, sıcak ama ciddi ol. Emoji KULLANMA.' : 'Write in English. No emojis.'}

7. **UZUNLUK:** Her "detailed" alanı EN AZ 4-5 cümle olsun. Kısa kesme, detaylı anlat.

8. **DÜRÜST OL, YAĞCILIK YAPMA:** Sen gerçek bir falcısın, motivasyon koçu değil! Her fal güzel çıkmaz. Kötü bir şey görüyorsan AÇIKÇA söyle. Yılan görüyorsan "Etrafında seni arkadan vuracak biri var" de. Koyu lekeler varsa "Ağır bir dönemden geçiyorsun" de. Dağ şekli varsa "Önünde büyük bir engel var" de. ASLA her şeyi güllük gülistanlık gösterme. Gerçek hayatta falcılar hem iyi hem kötü söyler — sen de öyle yap. Kötüyse kötü, iyiyse iyi. TARAF TUTMA.

JSON YAPISI (sadece JSON döndür, markdown yok):

{
  "cup_inside": {
    "title": "${isTr ? 'Fincan İçi' : 'Cup Inside'}",
    "short": "Fincanın genel enerjisini özetleyen kısa, etkileyici bir cümle",
    "detailed": "Fincanın içine baktığında gördüğün şekilleri tek tek say ve yorumla. Koyu bölgeler nerede, açık bölgeler nerede? Hangi şekiller belirmiş? Her şekli ayrı ayrı yorumla. En az 5 cümle."
  },
  "cup_side": {
    "title": "${isTr ? 'Fincan Kenarı' : 'Cup Side'}",
    "short": "Kenar şekillerinden çıkan en önemli mesaj",
    "detailed": "Sol ve sağ kenar fotoğraflarında gördüğün şekilleri anlat. Sol taraf geçmişi, sağ taraf geleceği temsil eder. Hangi şekiller var? Ne anlama geliyor? En az 5 cümle."
  },
  "cup_bottom": {
    "title": "${isTr ? 'Fincan Dibi' : 'Cup Bottom'}",
    "short": "Dibin verdiği en güçlü mesaj",
    "detailed": "Fincanın dibi kişinin iç dünyasını ve derin duygularını gösterir. Dip temiz mi yoksa koyu ve yoğun mu? Hangi şekiller birikmiş? Bu ne anlama geliyor? En az 4 cümle."
  },
  "saucer": {
    "title": "${isTr ? 'Tabak' : 'Saucer'}",
    "short": "Tabağın verdiği en net mesaj",
    "detailed": "Tabak kişinin kalbini ve evini temsil eder. Tabakta telveler nasıl dağılmış? Hangi şekiller oluşmuş? Dilekler kabul olacak mı? En az 4 cümle."
  },
  "story": "Tüm fincandan çıkan büyük resmi anlat. Bu kişinin şu an hayatında neler oluyor, neler değişmek üzere? Fincanın sana fısıldadığı hikayeyi 5-6 cümleyle net ve etkileyici biçimde özetle. Lafı dolandırma, doğrudan söyle.",
  "symbols": [
    {"name": "Şekil adı", "meaning": "En fazla 6-7 kelimelik KISA açıklama", "icon": "flutter_icon_name"}
  ],
  "love": "Aşk ve ilişkiler hakkında NET tahminler. Kalp şekli var mı? İki figür yan yana mı? Tek bir siluet mi? Bunlardan yola çıkarak cesur yorumlar yap. En az 3 cümle.",
  "career": "Kariyer ve para hakkında NET tahminler. Yükselen çizgiler var mı? Balık şekli? Kapı? Anahtar? Bunlardan somut tahminler çıkar. En az 3 cümle.",
  "family": "Aile ve ev hakkında NET tahminler. Kümelenmiş telveler var mı? Ev şekli? Ağaç? Bunları yorumla. En az 3 cümle.",
  "near_future": [
    {"time": "${isTr ? 'Birkaç Gün İçinde' : 'In a Few Days'}", "prediction": "Çok spesifik ve net bir tahmin — örn: 'Seni arayacak biri var, telefonu açmayı ihmal etme'"},
    {"time": "${isTr ? '2-3 Hafta İçinde' : 'In 2-3 Weeks'}", "prediction": "Net ve cesur bir tahmin"},
    {"time": "${isTr ? '40 Gün İçinde' : 'Within 40 Days'}", "prediction": "Hayatında önemli bir dönüm noktası olacak bir tahmin"}
  ],
  "wish": "Tabağa baktığında dileğin kabul olup olmayacağını NET söyle. 'Belki olur belki olmaz' gibi kaçamak cevap verme. 2-3 cümle.",
  "advice": "Falın son sözü olarak güçlü, akılda kalıcı, kısa bir öğüt ver. Filozof gibi değil, bilge bir nine gibi konuş.",
  "image_map": {
    "cup_inside": 1,
    "cup_side": 2,
    "cup_bottom": 3,
    "saucer": 4
  }
}

ÖNEMLİ: "image_map" alanında her bölüm için HANGİ FOTOĞRAFI (1, 2, 3 veya 4) kullandığını belirt. Örneğin tabak fotoğrafı 2. sıradaysa: "saucer": 2 yaz. Bu sayede doğru fotoğraf doğru bölümle eşleşir.

ICON MAPPING (use these exact strings):
- edit_road_rounded = yol/süreç/mesafe
- flutter_dash_rounded = kuş/haber/özgürlük
- favorite_rounded = kalp/duygu/bağ
- vpn_key_rounded = anahtar/çözüm/sır
- radio_button_unchecked_rounded = döngü/tamamlanma/yüzük
- access_time_rounded = zaman/bekleyiş
- visibility_rounded = göz/nazar/farkındalık
- pets_rounded = hayvan/içgüdü/dost
- park_rounded = ağaç/kök/büyüme
- water_drop_rounded = su/gözyaşı/arınma
- home_rounded = ev/yuva/güven
- mail_rounded = mektup/mesaj/iletişim
- star_rounded = yıldız/şans/kader
- nightlight_rounded = ay/gizemi/bilinçaltı

Return ONLY valid JSON, no markdown.`;

      const imageContents = images.map((img: string) => ({
        type: "image_url",
        image_url: {
          url: `data:image/jpeg;base64,${img}`,
          detail: "high", // Yorum için yüksek çözünürlük
        },
      }));

      // Asenkron işleyici
      const processCoffee = async () => {
        try {
          const response = await fetch(OPENAI_URL, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${OPENAI_API_KEY}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: systemPrompt },
                {
                  role: "user",
                  content: [
                    { type: "text", text: "Sana 4 kahve falı fotoğrafı gönderiyorum. ÖNEMLİ: Fotoğraflar herhangi bir sırada olabilir! Önce her fotoğrafa bak ve kendin belirle hangisi fincan içi, hangisi sol kenar, hangisi sağ kenar, hangisi tabak. Tabak düz ve geniş bir yüzeydir (fincanın altlığı). Fincan içi derin ve yukarıdan çekilmiştir. Kenarlar ise fincanın yan taraflarını gösterir. Doğru eşleştirmeyi yaptıktan sonra falı bak." },
                    ...imageContents,
                  ],
                },
              ],
              temperature: 0.7,
              max_tokens: 3500,
              response_format: { type: "json_object" },
            }),
          });

          if (!response.ok) {
            console.error("OpenAI interpret error:", response.status, await response.text());
            throw new Error("AI service unavailable");
          }

          const data = await response.json();
          const rawContent = data.choices?.[0]?.message?.content;
          if (!rawContent) throw new Error("Empty AI response");

          const parsed = JSON.parse(rawContent);

          // siz → sen post-processing
          const fix = (t: string): string => {
            if (!t) return t;
            if (!isTr) return t;
            return t
              .replace(/Fincanınız/g, 'Fincanın').replace(/fincanınız/g, 'fincanın')
              .replace(/Falınız/g, 'Falın').replace(/falınız/g, 'falın')
              .replace(/hayatınız/g, 'hayatın').replace(/ilişkiniz/g, 'ilişkin')
              .replace(/Dileğiniz/g, 'Dileğin').replace(/dileğiniz/g, 'dileğin')
              .replace(/yaşadığınız/g, 'yaşadığın').replace(/hissettiğiniz/g, 'hissettiğin')
              .replace(/olmanız/g, 'olman').replace(/kalmanız/g, 'kalman')
              .replace(/yapmanız/g, 'yapman').replace(/bakmanız/g, 'bakman')
              .replace(/gösteriyorsunuz/g, 'gösteriyorsun').replace(/taşıyorsunuz/g, 'taşıyorsun');
          };

          const deepFix = (obj: any): any => {
            if (typeof obj === 'string') return fix(obj);
            if (Array.isArray(obj)) return obj.map(deepFix);
            if (obj && typeof obj === 'object') {
              const result: any = {};
              for (const [key, val] of Object.entries(obj)) {
                result[key] = deepFix(val);
              }
              return result;
            }
            return obj;
          };

          const fixedResult = deepFix(parsed);

          const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
          const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
          const supabase = createClient(supabaseUrl, supabaseKey);

          // 1. Veritabanını Güncelle
          if (record_id) {
            await supabase.from('coffee_readings').update({
              status: 'completed',
              result: fixedResult
            }).eq('id', record_id);
          }

          // 2. Push Notification Gönder (doğrudan Firebase Admin)
          if (userId) {
            try {
              const { data: receiverData } = await supabase.from('profiles').select('fcm_token').eq('id', userId).single();
              const fcmToken = receiverData?.fcm_token;
              console.log(`FCM token for ${userId}:`, fcmToken ? 'EXISTS' : 'MISSING');
              
              if (fcmToken && admin.apps.length > 0) {
                const isTr = locale === 'tr';
                const pushTitle = isTr ? 'Kahve Falın Hazır! ☕️' : 'Coffee Reading Ready! ☕️';
                const pushBody = isTr ? 'Fincanındaki sırlar çözüldü. Hemen okumaya başla ✨' : 'The secrets in your cup have been revealed ✨';
                
                const firebaseResponse = await admin.messaging().send({
                  token: fcmToken,
                  notification: { title: pushTitle, body: pushBody },
                  data: { type: 'coffee_reading_ready' },
                  android: { notification: { sound: 'default' } },
                  apns: {
                    headers: { 'apns-priority': '10' },
                    payload: { aps: { sound: 'default', badge: 1, 'content-available': 1 } }
                  }
                });
                console.log('✅ Firebase push sent successfully:', firebaseResponse);
              } else {
                console.log('⚠️ Skipped push: fcmToken=' + !!fcmToken + ', firebase=' + (admin.apps.length > 0));
              }
            } catch (notifyErr) {
              console.error('Push notification failed, but continuing:', notifyErr);
            }
          }

          return fixedResult; // Önemli: Sonucu döndür!
        } catch (err) {
          console.error("Processing error:", err);
          if (record_id) {
            const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
            const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
            const supabase = createClient(supabaseUrl, supabaseKey);
            await supabase.from('coffee_readings').update({
              status: 'failed'
            }).eq('id', record_id);
          }
          throw err;
        }
      };

      // HİBRİT YAKLAŞIM:
      // 1. EdgeRuntime.waitUntil ile sunucunun işi arka planda bitirmesini garanti altına al
      // 2. Aynı promise'i await ederek, istemci hala bağlıysa sonucu doğrudan dön
      const taskPromise = processCoffee();
      EdgeRuntime.waitUntil(taskPromise);

      try {
        const fixedResult = await taskPromise;
        return new Response(JSON.stringify(fixedResult), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      } catch (bgErr) {
        return new Response(JSON.stringify({ status: "processing" }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    return new Response(
      JSON.stringify({ error: "Invalid mode. Use 'validate' or 'interpret'" }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Function error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
