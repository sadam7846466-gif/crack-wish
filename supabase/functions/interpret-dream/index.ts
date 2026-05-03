import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!;
const OPENAI_URL = "https://api.openai.com/v1/chat/completions";
const MODEL = "gpt-4o-mini";

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
    const { dreamText, emotion, locale } = await req.json();

    if (!dreamText || dreamText.trim().length < 10) {
      return new Response(
        JSON.stringify({ error: "Dream text too short" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const isTr = locale === "tr";

    const systemPrompt = `You are a scientific dream analyst.

Your job is to interpret dreams using psychology and neuroscience-based reasoning.

STRICT RULES:
- Do NOT predict the future.
- Do NOT use mystical, spiritual, religious, or fortune-telling language.
- Do NOT invent personal details, relationship problems, trauma, or life events unless they are clearly present in the dream text.
- Base the interpretation ONLY on the dream content and the selected waking emotion.
- First identify the single most important psychological conflict in the dream.
- Build the whole interpretation around that core conflict.
- Do NOT explain every symbol separately.
- Mention only the most relevant symbols if they directly support the core conflict.
- Avoid generic dream explanations.
- Avoid repetition.
- Keep the tone intelligent, grounded, and emotionally perceptive.
- Write in ${isTr ? 'Turkish. Use informal "sen" form, ALWAYS use correct possessive suffixes (e.g., "kendi korkularınla" NOT "kendi korkularla"), NEVER "siz".' : 'English.'}

QUALITY RULES:
- The response must feel specific to this exact dream, not dreams in general.
- Every sentence must directly connect to an element from the dream.
- If the analysis sounds generic, rewrite it to be more specific.
- Prioritize depth over coverage.
- Short, sharp, meaningful.
- Format with clear spacing: use '\\n\\n' to create paragraphs and line breaks.

EMOTION RULE:
- The emotional interpretation should align with the user's selected waking emotion unless the dream strongly contradicts it.
- If there is a mismatch, describe it as a mixed or layered emotional state instead of forcing a wrong emotion.
- If the emotion is 'Belirsizlik' (Uncertainty), avoid defaulting to 'Kaygı' (Anxiety) all the time. Explore other nuances like curiosity, transition, seeking, or potential.

PERCENTAGE RULES:
- emotional_load = emotional intensity, fear, stress, pain, guilt, protection burden
- uncertainty = lack of control, instability, unclear outcome
- recent_memory_effect = likely connection to current concerns or recent life events
- brain_activity = AGENCY/CONTROL. High = active decision making. Low = passive observation.
- The reasoning text MUST logically match the percentage value (e.g. if you give 30%, the text must explain why it's LOW. Never say it's high).
- Each percentage is an independent score from 0 to 100. They DO NOT need to sum to 100.
- Ensure the scores accurately reflect the intensity of each metric in the dream.

OUTPUT RULES:
- Return ONLY valid JSON.
- No markdown.
- No explanation outside JSON.

EXAMPLE OF GOOD STYLE:

Dream:
"I was trapped in a cage with my partner and others. I got out, but they remained inside. Then the cage fell and I suffered because of what happened to them."

Good interpretation style:
- Focus on the conflict between self-protection and responsibility toward others.
- Keep the language concise.
- Use explicit bullet styles like "→" for linking actions and "➤" for insights.
- Do not over-explain every symbol.
- Do not invent relationship problems.
- Make the meaning feel specific and psychologically grounded.

VALIDATION RULE:
- First, check if the text is actually a dream or a psychological experience.
- If the text is clearly spam, a news article, stock market prices, random letters, or completely unrelated to a dream (e.g., "Dolar kuru", "sadasdasda"), set "is_valid_dream" to false and return empty strings for the rest.`;

    const userPrompt = `Analyze this dream.

Dream text:
${dreamText}

Selected waking emotion:
${emotion}

Return this exact JSON structure:

{
  "is_valid_dream": true,
  "core_conflict": "string",
  "distribution": {
    "emotional_load": {"value": 0, "reasoning": "MAX 15 words. If value < 40, state emotions were LOW/CALM. If > 60, state they were HIGH/INTENSE."},
    "uncertainty": {"value": 0, "reasoning": "MAX 15 words. If value < 40, state narrative was LOGICAL. If > 60, state it was CHAOTIC."},
    "recent_memory_effect": {"value": 0, "reasoning": "MAX 15 words. If value < 40, explicitly state it is NOT connected to recent events. If > 60, state it IS connected."},
    "brain_activity": {"value": 0, "reasoning": "MAX 15 words. (AGENCY/CONTROL). If value < 40, state dreamer was PASSIVE. If > 60, state dreamer was ACTIVE."}
  },
  "analysis": {
    "brain": "Short brain process explanation. 2-3 sentences max.",
    "emotion": "Dominant emotion analysis. MUST use → for mapping and ➤ for conclusion. E.g. 'X → Y \\n\\n➤ Z'",
    "symbol": "Core symbol explanation. MUST use = for meaning, → for mapping, ➤ for conclusion.",
    "nature": "OPTIONAL: Environment analysis.",
    "physical_pain": "OPTIONAL: Physical sensation explanation.",
    "recent_effect": "OPTIONAL: Recent memory effect.",
    "summary": "Clear scientific summary. 2-3 sentences.",
    "advice": "Actionable psychological advice."
  }
}`;

    const response = await fetch(OPENAI_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: MODEL,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
        temperature: 0.4,
        max_completion_tokens: 800,
        response_format: { type: "json_object" },
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error("OpenAI error:", response.status, errText);
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

    if (parsed.is_valid_dream === false) {
      const invalidResult = {
        category: isTr ? "Geçersiz Metin" : "Invalid Content",
        distribution: { emotional_load: 0, uncertainty: 0, recent_memory_effect: 0, brain_activity: 0 },
        sections: [
          { emoji: "⚠️", title: isTr ? "Rüya Algılanamadı" : "No Dream Detected", content: isTr ? "Yazdıkların bir rüya anlatısı gibi görünmüyor (haber, arama terimi, döviz kuru, anlamsız metin vb.). Lütfen gerçekten gördüğün bir rüyayı yazdığından emin ol." : "This does not look like a dream narrative. Please make sure you are describing an actual dream." }
        ],
        summary: ""
      };
      return new Response(JSON.stringify(invalidResult), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // siz → sen post-processing
    const fix = (t: string): string => {
      if (!t) return t;
      // Strip all emoji characters (keep → ➤ and basic punctuation)
      let cleaned = t.replace(/[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1FA00}-\u{1FAFF}\u{FE00}-\u{FE0F}\u{200D}\u{20E3}\u{E0020}-\u{E007F}]/gu, '');
      // Clean up double spaces left by removed emojis
      cleaned = cleaned.replace(/  +/g, ' ').trim();
      if (!isTr) return cleaned;
      
      // Strip starting pronouns
      const startPronounRegex = /^(Sen,|Senin için,|Senin için|Sen)\s+/i;
      if (startPronounRegex.test(cleaned)) {
        cleaned = cleaned.replace(startPronounRegex, "");
        if (cleaned.length > 0) cleaned = cleaned.charAt(0).toUpperCase() + cleaned.slice(1);
      }

      return cleaned
        .replace(/Rüyanız/g,'Rüyan').replace(/rüyanız/g,'rüyan')
        .replace(/yaşadığınız/g,'yaşadığın').replace(/hissettiğiniz/g,'hissettiğin')
        .replace(/olmanız/g,'olman').replace(/kalmanız/g,'kalman')
        .replace(/korkunuz/g,'korkun').replace(/beyniniz/g,'beynin')
        .replace(/hayatınız/g,'hayatın').replace(/ilişkiniz/g,'ilişkin')
        .replace(/kendi korkularla/g, "kendi korkularınla")
        .replace(/kendi içsel korkularla/g, "kendi içsel korkularınla")
        .replace(/kendi düşüncelerle/g, "kendi düşüncelerinle")
        .replace(/kendi duygularla/g, "kendi duygularınla");
    };

    const a = parsed.analysis || {};

    // Flutter sections formatına dönüştür
    const sections = [];
    if (a.brain) sections.push({ emoji: "🧠", title: isTr ? "Beyin Ne Yapıyordu?" : "What Was the Brain Doing?", content: fix(a.brain) });
    if (a.emotion) sections.push({ emoji: "❤️", title: isTr ? "Baskın Duygusal Tema" : "Dominant Emotional Theme", content: fix(a.emotion) });
    if (a.symbol) sections.push({ emoji: "🧩", title: isTr ? "Ana Sembol" : "Main Symbol", content: fix(a.symbol) });
    if (a.nature && !a.nature.includes("OPTIONAL")) sections.push({ emoji: "🌲", title: isTr ? "Ortam & Doğa" : "Environment", content: fix(a.nature) });
    if (a.physical_pain && !a.physical_pain.includes("OPTIONAL")) sections.push({ emoji: "🌫", title: isTr ? "Fiziksel His" : "Physical Sensation", content: fix(a.physical_pain) });
    if (a.recent_effect && !a.recent_effect.includes("OPTIONAL")) sections.push({ emoji: "🔁", title: isTr ? "Yakın Zaman Etkisi" : "Recent Effect", content: fix(a.recent_effect) });
    if (a.summary) sections.push({ emoji: "🔬", title: isTr ? "Bilimsel Özet" : "Scientific Summary", content: fix(a.summary) });
    if (a.advice) sections.push({ emoji: "💡", title: isTr ? "Kendine Not" : "Note to Self", content: fix(a.advice) });

    const result = {
      category: fix(parsed.core_conflict || ""),
      distribution: parsed.distribution || { emotional_load: 25, uncertainty: 25, recent_memory_effect: 25, brain_activity: 25 },
      sections,
      summary: fix(parsed.core_conflict || ""), // summary = core_conflict (farklı içerik, duplikasyon yok)
    };

    // --- SEND PUSH NOTIFICATION ---
    try {
      if (userId) {
        // userId requires dynamic import if not defined, but we can extract it from the first req.json()
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
        const supabase = createClient(supabaseUrl, supabaseKey);

        await supabase.functions.invoke('push-notification', {
          body: {
            table: 'dreams',
            record: {
              to_user: userId,
              from_user: userId,
              locale: locale
            }
          }
        });
        console.log("Triggered push-notification for dream user", userId);
      }
    } catch(e) {
      console.error("FCM Error:", e);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Function error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
