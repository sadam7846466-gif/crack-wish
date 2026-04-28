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

      const validationPrompt = `You are a coffee cup reading photo validator. 
Analyze each of the 4 images and determine if they are valid Turkish coffee cup/saucer photos.

RULES:
- Image 1 should show the INSIDE of a coffee cup (telve/grounds visible)
- Image 2 should show the LEFT SIDE profile of a coffee cup
- Image 3 should show the RIGHT SIDE profile of a coffee cup  
- Image 4 should show a coffee SAUCER (tabak) with grounds

For each image, return:
- valid: true if it's a valid coffee reading photo, false if not
- error: null if valid, or a SHORT friendly error message in ${isTr ? 'Turkish (use "sen" form)' : 'English'}

Return ONLY valid JSON, no markdown:
{
  "results": [
    {"valid": true, "error": null},
    {"valid": false, "error": "Bu bir kahve fincanı fotoğrafı değil, lütfen fincanın iç kısmını çek."},
    {"valid": true, "error": null},
    {"valid": true, "error": null}
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

      const systemPrompt = `You are a warm, insightful Turkish coffee fortune teller (falcı). 
You read coffee cup grounds (telve) and saucer patterns to provide meaningful, personalized readings.

STYLE RULES:
- Write in ${isTr ? 'Turkish. Use informal "sen" form, NEVER "siz". Be warm, mystical but not cheesy.' : 'English. Be warm and mystical.'}
- Be specific — reference shapes, patterns, and positions you "see" in the grounds
- Each section should feel unique and personal, not generic
- Use poetic but grounded language
- DO NOT use emojis
- Format with clear spacing using '\\n\\n'

READING STRUCTURE:
Analyze all 4 images and return this JSON:

{
  "cup_inside": {
    "title": "${isTr ? 'Fincan İçi' : 'Cup Inside'}",
    "short": "One-line summary of what the inside represents",
    "detailed": "2-3 sentences about inner world, thoughts, emotions based on patterns seen"
  },
  "cup_side": {
    "title": "${isTr ? 'Kenar' : 'Side'}",
    "short": "One-line summary",
    "detailed": "2-3 sentences about near future, messages, communication"
  },
  "cup_bottom": {
    "title": "${isTr ? 'Dip' : 'Bottom'}",
    "short": "One-line summary",
    "detailed": "2-3 sentences about past, unresolved issues, roots"
  },
  "saucer": {
    "title": "${isTr ? 'Tabak' : 'Saucer'}",
    "short": "One-line summary",
    "detailed": "2-3 sentences about wishes, destiny, final energy"
  },
  "story": "The main narrative — 4-5 sentences connecting all parts into a cohesive fortune reading",
  "symbols": [
    {"name": "Symbol name", "meaning": "What it represents", "icon": "flutter_icon_name"},
    {"name": "Symbol name", "meaning": "What it represents", "icon": "flutter_icon_name"}
  ],
  "love": "2-3 sentences about love and relationships",
  "career": "2-3 sentences about career and money",
  "family": "2-3 sentences about family and close circle",
  "near_future": [
    {"time": "${isTr ? 'Çok Yakında' : 'Very Soon'}", "prediction": "Short prediction"},
    {"time": "${isTr ? '3 Vakte Kadar' : 'Within 3 Days'}", "prediction": "Short prediction"},
    {"time": "${isTr ? 'Zamanı Geldiğinde' : 'When the Time Comes'}", "prediction": "Short prediction"}
  ],
  "wish": "2-3 sentences about the person's wish/desire",
  "advice": "2-3 sentences of wisdom/advice from the fortune"
}

ICON MAPPING (use these Flutter icon names):
- edit_road_rounded = path/road
- flutter_dash_rounded = bird
- favorite_rounded = heart
- vpn_key_rounded = key
- radio_button_unchecked_rounded = ring/circle
- access_time_rounded = clock/time
- visibility_rounded = eye
- pets_rounded = animal
- park_rounded = tree
- water_drop_rounded = water
- home_rounded = house
- mail_rounded = letter/message

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
          model: "gpt-4o",
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
