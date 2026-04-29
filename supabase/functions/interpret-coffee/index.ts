import "jsr:@supabase/functions-js/edge-runtime.d.ts";

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
    const { mode, images, locale } = await req.json();
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

      const validationPrompt = `You are an elite, highly perceptive Turkish coffee cup reading photo validator. 
You are evaluating a SET of 4 images provided by the user for a coffee reading.

CRITICAL RULES FOR VALIDATION:
1. **Consistency (Crucial):** All 4 images MUST belong to the EXACT SAME coffee cup and saucer set. If you see a white cup in one image, and a red cup/different pattern in another, mark the inconsistent ones as invalid!
2. **Completeness & Content:** The set as a whole must contain the inside of the cup, the sides of the cup, and the saucer. The exact slot order is flexible, BUT if an image is just an exact duplicate of another, mark the redundant one as invalid.
3. **Relevance:** If an image is a face, a car, or not coffee-related, mark it as invalid.

For each of the 4 image slots, return:
- valid: true/false based on the rules above.
- error: null if valid. If invalid, provide a SHORT, specific, and friendly error message in ${isTr ? 'Turkish (use "sen" form)' : 'English'} explaining WHY it was rejected.

Examples of errors:
- "Bu fotoğraf diğerleriyle aynı fincana ait görünmüyor. Lütfen aynı fincanı çek." (For inconsistency)
- "Aynı fotoğrafı birden fazla kez yüklemişsin. Lütfen fincanın farklı bir açısını veya tabağı çek." (For exact duplicates)
- "Bu bir insan yüzü, lütfen kahve fincanını çek." (For unrelated images)

Return ONLY valid JSON, no markdown:
{
  "results": [
    {"valid": true, "error": null},
    {"valid": false, "error": "Bu fotoğraf diğerleriyle aynı fincana ait görünmüyor. Lütfen aynı fincanı çek."},
    {"valid": true, "error": null},
    {"valid": false, "error": "Aynı fotoğrafı tekrar yüklemişsin, lütfen tabağı çek."}
  ]
}`;

      const imageContents = images.map((img: string, i: number) => ({
        type: "image_url",
        image_url: {
          url: `data:image/jpeg;base64,${img}`,
          detail: "low", // Maliyet optimizasyonu: düşük çözünürlük yeterli
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
            { role: "system", content: validationPrompt },
            {
              role: "user",
              content: [
                { type: "text", text: "Validate these 4 coffee cup photos:" },
                ...imageContents,
              ],
            },
          ],
          temperature: 0.1,
          max_completion_tokens: 300,
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

      const systemPrompt = `You are a profoundly intuitive and authentic Turkish coffee fortune teller (falcı) with decades of experience. 
You are performing a deeply psychological and mystical reading based EXACTLY on the actual coffee grounds (telve) visible in the 4 images provided.

CRITICAL RULES FOR REALISM:
1. **ACTUAL VISUAL ANALYSIS:** You MUST analyze the actual images. Point out specific visual evidence: "Dipte birikmiş koyu bir telve yığını var...", "Fincanın sağ kenarına doğru açılan aydınlık bir yol (ferahlık) görüyorum...", "Şurada beliren 'M' harfine benzer bir siluet...". Do not make up shapes that aren't there. If the cup is mostly dark, talk about density/stress. If it's light, talk about clarity/relief.
2. **TONE:** Write in ${isTr ? 'Turkish. Use informal "sen" form. Be profound, serious, deeply psychological, and slightly cryptic. NEVER use cheesy, generic horoscope phrases.' : 'English. Be profound, serious, and deeply psychological.'}
3. **NO EMOJIS:** Absolutely no emojis.
4. **DEPTH:** Treat the coffee cup as a mirror to their subconscious. Connect the shapes to real human emotions (past traumas, suppressed desires, upcoming opportunities).

READING STRUCTURE:
Analyze all 4 images and return this JSON strictly. DO NOT use markdown blocks outside the JSON:

{
  "cup_inside": {
    "title": "${isTr ? 'Fincan İçi' : 'Cup Inside'}",
    "short": "One cryptic, poetic line about their inner state",
    "detailed": "3 sentences analyzing the overall contrast (light/dark) of the inside image. Explain their current mental/emotional state based on the density of the grounds."
  },
  "cup_side": {
    "title": "${isTr ? 'Kenar' : 'Side'}",
    "short": "One cryptic line about approaching events",
    "detailed": "3 sentences analyzing specific shapes on the left/right edges. What is entering or leaving their life?"
  },
  "cup_bottom": {
    "title": "${isTr ? 'Dip' : 'Bottom'}",
    "short": "One cryptic line about their roots/past",
    "detailed": "3 sentences strictly analyzing the bottom of the cup. Is there a thick dark blob (unresolved grief) or is it clear (letting go)?"
  },
  "saucer": {
    "title": "${isTr ? 'Tabak' : 'Saucer'}",
    "short": "One cryptic line about the outcome",
    "detailed": "3 sentences analyzing the saucer image. Describe the flow of the liquid/grounds. Are their tears/wishes flowing freely or stuck?"
  },
  "story": "The Cosmic Narrative: 4-5 sentences interweaving the visual elements into a deep, cohesive story about their current life chapter.",
  "symbols": [
    {"name": "Symbol name (e.g., Kuş, Yol, Göz)", "meaning": "Deep psychological meaning", "icon": "flutter_icon_name"},
    {"name": "Symbol name", "meaning": "Deep psychological meaning", "icon": "flutter_icon_name"}
  ],
  "love": "3 sentences about love/relationships based on the proximity of shapes in the cup.",
  "career": "3 sentences about career/finances based on upward/downward lines in the cup.",
  "family": "3 sentences about family based on clustered grounds.",
  "near_future": [
    {"time": "${isTr ? 'Çok Yakında' : 'Very Soon'}", "prediction": "A highly specific, serious prediction"},
    {"time": "${isTr ? '3 Vakte Kadar' : 'Within 3 Days'}", "prediction": "A highly specific, serious prediction"},
    {"time": "${isTr ? 'Zamanı Geldiğinde' : 'When the Time Comes'}", "prediction": "A deeply philosophical outcome"}
  ],
  "wish": "2 sentences addressing the intention held in the saucer.",
  "advice": "A profound, mystical piece of advice acting as the final word."
}

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
                { type: "text", text: "Read this Turkish coffee cup fortune. Image 1: Cup inside, Image 2: Left side, Image 3: Right side, Image 4: Saucer." },
                ...imageContents,
              ],
            },
          ],
          temperature: 0.7,
          max_completion_tokens: 2000,
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
