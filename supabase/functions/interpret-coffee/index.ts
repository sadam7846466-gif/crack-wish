import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"

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
    const { mode, images, locale, userId } = await req.json();
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

VALIDATION CHECKLIST:
1. **Is it coffee?** Every image MUST clearly show a coffee cup, saucer, or coffee grounds. Be STRICT. If an image is just a blank wall, a face, or something completely unrelated, you MUST FAIL it.
2. **No Identical Clones:** FAIL an image if the exact same file is uploaded twice.
3. **Must Have a Saucer (Tabak):** Look at ALL 4 images. At least ONE of them MUST be a saucer (a flat plate, usually under the cup). If none of the 4 images is a saucer, you MUST FAIL the 4th image.

If an image fails, provide a SHORT, friendly error message in ${isTr ? 'Turkish (use "sen" form)' : 'English'}.

Examples of errors:
- "Lütfen geçerli bir kahve fincanı veya tabağı fotoğrafı yükle."
- "Aynı fotoğrafı iki kez yüklemişsin. Lütfen farklı bir açı çek."
- "Tabak fotoğrafı eksik. Lütfen fincanla birlikte tabağın da fotoğrafını yükle."

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

4. **ŞEKİLLERİ YORUMLA:** Kahve falında klasik şekiller: Kuş (haber), Yol (yolculuk/değişim), Göz (nazar/kıskançlık), Kalp (aşk), Ağaç (aile/kök), Yılan (düşman/dedikodu), Halka/Yüzük (evlilik/nişan), Balık (para/bereket), At (güç/hız), Köpek (sadık dost), Kedi (ihanet/aldatma), Anahtar (çözüm), Kapı (fırsat), Dağ (engel), Çiçek (mutluluk).

5. **HİSSETTİR:** Kişi falı okuduktan sonra "Vay be, gerçekten baktı fincanıma" demeli. Jenerik, her fincan için geçerli cümleler YAZMA. O fincanın kendine özgü hikayesini anlat.

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
        const errText = await response.text();
        console.error("OpenAI interpret error:", response.status, errText);
        return new Response(
          JSON.stringify({ error: "AI service unavailable", detail: errText }),
          { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const data = await response.json();
      const rawContent = data.choices?.[0]?.message?.content;

      if (!rawContent) {
        console.error("Empty AI response:", JSON.stringify(data));
        return new Response(
          JSON.stringify({ error: "Empty AI response" }),
          { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

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

      // Deep fix all string values
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

      // --- SEND PUSH NOTIFICATION ---
      try {
        if (userId) {
          const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
          const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
          const supabase = createClient(supabaseUrl, supabaseKey);

          await supabase.functions.invoke('push-notification', {
            body: {
              table: 'coffee_reading',
              record: {
                to_user: userId,
                from_user: userId, // Kendisinden geliyormuş gibi yapabiliriz
                locale: locale
              }
            }
          });
          console.log("Triggered push-notification for user", userId);
        }
      } catch(e) {
        console.error("FCM Error:", e);
      }

      return new Response(JSON.stringify(fixedResult), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
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
