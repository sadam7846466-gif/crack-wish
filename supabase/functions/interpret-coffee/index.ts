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
    const { mode, images, locale, userId, record_id, gender, zodiac, relationship, intent } = await req.json();
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

      // Profil bağlamını oluştur (varsa)
      let profileContext = '';
      if (gender || zodiac || relationship || intent) {
        const parts: string[] = [];
        if (gender && gender !== 'Belirtmek İstemiyorum') parts.push(`Cinsiyet: ${gender}`);
        if (zodiac) parts.push(`Burç: ${zodiac}`);
        if (relationship) parts.push(`İlişki durumu: ${relationship}`);
        if (intent) parts.push(`Kişinin Odaklandığı Niyet/Dilek: ${intent}`);
        
        if (parts.length > 0) {
          profileContext = `\n\nKARŞINDAKİ KİŞİNİN PROFİLİ VE NİYETİ:\n${parts.join('\n')}\n\nBu bilgileri falda KULLANMALISIN. Özellikle fincanı kapatırken tuttuğu "Niyet/Dilek" (${intent || 'belirsiz'}) senin temel odak noktan olmalı. Eğer niyeti "Kariyer" ise kariyer alanını, "Aşk" ise aşk bölümünü merkeze al ve niyetine çok net, kesin bir cevap ver. Tüm bunları falın içine tamamen DOĞAL ve hisli bir dille yedir. Asla "niyetin şu olduğu için" gibi mekanik kalıplar kullanma, mistik bir dille sezmişsin gibi aktar.`;
        }

        // İLİŞKİ DURUMUNA GÖRE SERT KURALLAR
        if (relationship) {
          const r = relationship.toLowerCase();
          if (r.includes('evli') || r.includes('nişanlı') || r.includes('ilişkisi var') || r.includes('birlikte')) {
            profileContext += `\n\n🚨 KRİTİK İLİŞKİ KURALI — ASLA İHLAL ETME:\nBu kişi ${relationship} durumunda. Bu yüzden:\n- ASLA "yeni bir aşk", "tanışacağın biri", "yeni bir ilişki", "kapı aralayacak", "birini tanıyacaksın", "hayatına biri girecek" gibi ifadeler KULLANMA.\n- ASLA Yakın Gelecek bölümünde "yeni bir ilişki" veya "yeni biriyle tanışma" tahmini YAPMA.\n- Aşk & İlişkiler bölümünde mevcut ilişkisine/evliliğine odaklan: bağın güçlenmesi, sadakat, eşiyle olan iletişim, aile içi huzur, birlikte yapılacak planlar gibi konulara değin.\n- Eğer fincanda romantik figürler görüyorsan bunları mevcut eşi/partneriyle ilgili yorumla (örneğin: eşinle aranızdaki bağ güçlenecek, partnerinle birlikte yeni bir sayfa açacaksınız).\n- Bu kural Aşk bölümü, Yakın Gelecek bölümü, Hikaye bölümü ve Tavsiye bölümü dahil TÜM BÖLÜMLER için geçerlidir.`;
          } else if (r.includes('bekar') || r.includes('yalnız') || r.includes('ayrılmış') || r.includes('boşanmış')) {
            profileContext += `\n\nİLİŞKİ BAĞLAMI:\nBu kişi ${relationship} durumunda. Aşk & İlişkiler bölümünde yeni tanışmalar, potansiyel ilişkiler veya romantik fırsatlardan bahsedebilirsin. Ancak yine de her falda romantik tahmin zorunlu değil — fincandaki figürlere bağlı kal.`;
          }
        }
      }

      const systemPrompt = `Sen yıllardır kahve falı bakan, deneyimli ve MÜTHİŞ YARATICI bir Türk falcısısın. Karşında oturan kişinin fincanına ve tabağına bakıyorsun.${profileContext}

YASAKLI KELİMELER VE İFADELER (BUNLARI ASLA KULLANMA):
- "Koyu leke", "kahve kalıntısı", "belirsiz şekil", "karışık bir görünüm", "yoğun telve", "fincanın kenarında birikmiş kahve". Bunlar yerine spesifik figürler gör: şaha kalkmış bir at, boynu bükük bir kadın, kanatlarını açmış kartal, iki başlı ejderha, sırtını dönmüş bir adam gibi. Telvenin leke olduğunu herkes biliyor, sen onlardan anlamlı şekiller çıkaracaksın!
- "Geçmişte kalmış bir aşk var, etkisi hala sürüyor." gibi klişeler. Herkese aynı şeyi söyleme. Çeşitlendir!

YASAKLI SEMBOL İSİMLERİ (symbols alanında bu isimleri ASLA kullanma, çok klişe):
- Dağ, Güneş, Kuş, Yılan, Ağaç, Kalp, Yıldız, Ay, Göz — bunlar her falda çıkıyor ve sahte görünüyor!
- Bunların yerine FOTOĞRAFA ÖZGÜ, yaratıcı isimler kullan. Örnek alternatifler: Kanatlı Kartal, Tilki Silueti, Kırık Zincir, Dans Eden Kadın, Yelkenli, Taç, Kılıç, Ahtapot, Kelebek, Aslan Yelesi, Pusula, Terazi, Meşale, Fener, İncir Yaprağı, Kurt, Baykuş, Lir, Çapa, Deniz Kabuğu, Boğa, Papağan, Maske, Ayna, Halat Düğümü, Samuray, Ejderha Kuyruğu...

KRİTİK FORMAT KURALI: Metin içinde ASLA tırnak işareti (\", «, ») kullanma. Şekil isimlerini, figürleri, vurgulamak istediğin kelimeleri tırnak içine ALMA. Düz metin olarak, cümlenin doğal bir parçası gibi yaz. Örneğin yanlış: Fincanda "şaha kalkmış bir at" görüyorum. Doğru: Fincanda şaha kalkmış bir at görüyorum.

SEN BİR FALCISIN, FİLOZOF DEĞİL! Kurallar:

1. **ŞEKİLLERİ İSİMLENDİR VE DETAYLANDIR:** Fincanda sıradan bir leke görmüyorsun. Kenarda boynuzlu bir geyik şekli belirmiş, bu sana inatçı biriyle yaşayacağın bir tartışmayı gösteriyor. Tabakta koca bir çınar ağacı kök salmış. Böyle somut figürler bul ve yorumla.

2. **KİŞİSELLEŞTİR:** Her fal %100 birbirinden BAMBAŞKA olmalı. Bazı fallar tamamen kariyere odaklansın, bazıları bir aile sırrına, bazıları maddi bir kayba veya kazanca. Herkese güzel haber alacaksın deme!

3. **SPESIFIK OL:** Her bölümde fincanın/tabağın hangi kısmına baktığını belirt. Sol kenarda, sağ tarafta, fincanın dibinde, tabağın ortasında gibi.

4. **NET TAHMİNLER YAP:** Lafı dolandırma. Yuvarlak konuşma. KESİN konuş. AMA ASLA harf tahmini yapma! "A harfi ile başlayan biri", "M harfli bir kişi" gibi ifadeler YASAK. Bunlar sahte ve klişe. Bunun yerine kişiyi tanımlayıcı özellikler kullan: uzun boylu biri, esmer biri, yaşça büyük biri, uzaktan gelen biri gibi.

5. **HİSSETTİR:** Kişi falı okuduktan sonra gerçekten baktı fincanıma demeli. Fincanın kendine özgü, spesifik hikayesini anlat.

6. **DİL:** ${isTr ? 'Türkçe yaz. Sen diye hitap et. Gizemli, eski toprak bir bilge gibi konuş. Emoji KULLANMA. Tırnak işareti KULLANMA.' : 'Write in English. Mystical tone. No emojis. No quotation marks.'}

7. **UZUNLUK:** Her detailed alanı 3 cümle olsun. Kısa ve öz yaz, uzatma. Kullanıcı okumaktan sıkılmamalı.

8. **DÜRÜST OL, YAĞCILIK YAPMA:** Sen gerçek bir falcısın, motivasyon koçu değil! Her fal güzel çıkmaz. Kötü bir şey görüyorsan AÇIKÇA söyle. Yılan görüyorsan etrafında seni arkadan vuracak biri var de. Dağ şekli varsa önünde büyük bir engel var de. ASLA her şeyi güllük gülistanlık gösterme. Gerçek hayatta falcılar hem iyi hem kötü söyler — sen de öyle yap.

9. **TEKRARSİZLİK VE CÜMLE ÇEŞİTLİLİĞİ:** Her fal benzersiz olmalı. Aşağıdaki YASAKLI cümle kalıplarını ASLA kullanma:
  - "...görüyorum; bu, ... gösteriyor/simgeliyor/anlatıyor/işaret ediyor" (HER CÜMLEDE AYNI KALIP!)
  - "Fakat bu ... içinde..."
  - "Yani zorlu bir dönemdesin ama..."
  - "Bu figür/şekil seni ... olduğunu anlatıyor"
  - "...belirmiş; bu, ... işaret ediyor"
  Bu kalıplar çok robotik ve sahte. Bunun yerine her paragrafta FARKLI anlatım tekniği kullan:
  - Bazen doğrudan hitap et: "Dikkat et, yakınlarından biri senden bir şey saklıyor."
  - Bazen hikaye anlat: "Fincanın kenarında bir yelkenli belirmiş, sanki uzun bir yolculuğa çıkmak üzeresin."
  - Bazen uyarı ver: "Sağ taraftaki gölge seni uyarıyor — acele kararlar verme."
  - Bazen müjde ver: "Sol kenardaki çiçek açmış, beklediğin haber yolda."
  Her bölüm (cup_inside, cup_side, cup_bottom, saucer) farklı bir üslupla yazılmalı. Birinde sert ve uyarıcı ol, diğerinde yumuşak ve umut verici ol, bir diğerinde gizemli ve merak uyandırıcı ol.

10. **BÖLÜM SONUNDA ÖZET YAPMA:** Her bölümün detailed alanında ASLA "Genel olarak...", "Özetle...", "Tüm bu figürler..." gibi özet cümleleri ekleme. Her bölüm sadece o bölümdeki figürleri ve tahminleri anlatsın. Genel özet sadece "story" alanında yapılır.

JSON YAPISI (sadece JSON döndür, markdown yok):

{
  "cup_inside": {
    "title": "${isTr ? 'Fincan İçi' : 'Cup Inside'}",
    "short": "Fincanın genel enerjisini özetleyen kısa, etkileyici bir cümle",
    "detailed": "Fincanın içinde gördüğün en belirgin 2 şekli say ve yorumla. Maksimum 3 cümle. Özet yapma."
  },
  "cup_side": {
    "title": "${isTr ? 'Fincan Kenarı' : 'Cup Side'}",
    "short": "Kenar şekillerinden çıkan en önemli mesaj",
    "detailed": "Sol kenar geçmişi, sağ kenar geleceği temsil eder. Her kenardan 1 şekil seç ve yorumla. Maksimum 3 cümle."
  },
  "cup_bottom": {
    "title": "${isTr ? 'Fincan Dibi' : 'Cup Bottom'}",
    "short": "Dibin verdiği en güçlü mesaj",
    "detailed": "Fincanın dibi kişinin iç dünyasını gösterir. En belirgin şekli bul ve yorumla. Maksimum 3 cümle."
  },
  "saucer": {
    "title": "${isTr ? 'Tabak' : 'Saucer'}",
    "short": "Tabağın verdiği en net mesaj",
    "detailed": "Tabakta en belirgin şekli bul, dileğin durumunu söyle. Maksimum 3 cümle."
  },
  "story": "Tüm fincandan çıkan büyük resmi anlat. 3-4 cümleyle net ve etkileyici biçimde özetle. Lafı dolandırma.",
  "symbols": [
    {"name": "FOTOĞRAFTA GÖRDÜĞÜN ŞEKLİN YARATICI İSMİ (klişe Dağ/Güneş/Kuş/Yılan YASAK! Her falda farklı, özgün isimler kullan)", "meaning": "En fazla 4-5 kelimelik çok KISA açıklama", "icon": "flutter_icon_name"}
  ],
  "love": "Aşk ve ilişkiler hakkında NET ve CESUR tahminler. 2-3 cümle.",
  "career": "Kariyer ve para hakkında NET tahminler. 2-3 cümle.",
  "family": "Aile ve ev hakkında NET tahminler. 2-3 cümle.",
  "near_future": [
    {"time": "${isTr ? 'KENDİN BELİRLE — Mistik ve belirsiz yakın zaman ifadesi kullan. ASLA rakam verme. Örnekler: Çok Yakında, Yakın Günlerde, Rüzgar Yön Değiştirdiğinde, Güneş Kapını Çaldığında' : 'YOU DECIDE — Use mystical near-time phrases like Very Soon, In Coming Days'}", "prediction": "Bu fincana özel, benzersiz ve spesifik bir tahmin"},
    {"time": "${isTr ? 'KENDİN BELİRLE — Mistik ve belirsiz orta vadeli ifade kullan. ASLA rakam verme. Örnekler: Mevsim Dönerken, Ay Hilal Olduğunda, Yapraklar Düşmeden, Dolunay Dönerken' : 'YOU DECIDE — Use mystical mid-term phrases like When The Moon Turns'}", "prediction": "Farklı bir konuda cesur ve net bir tahmin"},
    {"time": "${isTr ? 'KENDİN BELİRLE — Mistik ve belirsiz uzun vadeli ifade kullan. ASLA rakam verme. Örnekler: Yıldızlar Hizalandığında, Mevsimler Değiştiğinde, Kader Kapıyı Çaldığında, Zaman Olgunlaştığında' : 'YOU DECIDE — Use mystical long-term phrases like When Stars Align'}", "prediction": "Hayatında dönüm noktası olacak büyük bir tahmin"}
  ],
  "closing": "Dileğin kabul olup olmayacağını söyle VE falın son sözü olarak güçlü, akılda kalıcı bir öğüt ver. Bilge bir nine gibi konuş. 2-3 cümle, tek paragraf.",
  "image_map": {
    "cup_inside": 1,
    "cup_side": 2,
    "cup_bottom": 3,
    "saucer": 4
  }
}

ÖNEMLİ: "image_map" alanında her bölüm için HANGİ FOTOĞRAFI (1, 2, 3 veya 4) kullandığını belirt. Örneğin tabak fotoğrafı 2. sıradaysa: "saucer": 2 yaz. Bu sayede doğru fotoğraf doğru bölümle eşleşir.

ICON MAPPING (use these exact strings — EN YAKIN OLANINI SEÇ):
- edit_road_rounded = yol/süreç/mesafe/yolculuk
- flutter_dash_rounded = kuş/kanat/uçuş/özgürlük
- favorite_rounded = kalp/duygu/bağ/aşk
- vpn_key_rounded = anahtar/çözüm/sır/kilit
- radio_button_unchecked_rounded = döngü/tamamlanma/yüzük/halka
- access_time_rounded = zaman/bekleyiş/saat/süreç
- visibility_rounded = göz/nazar/farkındalık/bakış
- pets_rounded = hayvan/içgüdü/dost/pati
- park_rounded = ağaç/kök/büyüme/yaprak/bitki
- water_drop_rounded = su/gözyaşı/arınma/damla
- home_rounded = ev/yuva/güven/barınak/aile
- mail_rounded = mektup/mesaj/iletişim/haber
- star_rounded = yıldız/şans/kader/parlama
- nightlight_rounded = ay/gizem/bilinçaltı/gece
- local_fire_department_rounded = ateş/tutku/enerji/meşale
- anchor_rounded = çapa/denge/bağlılık/liman
- psychology_rounded = insan/siluet/ruh/zihin
- sailing_rounded = yelken/deniz/yolculuk/macera
- shield_rounded = kalkan/koruma/güç/savunma
- diamond_rounded = değer/mücevher/nadir/taş

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
