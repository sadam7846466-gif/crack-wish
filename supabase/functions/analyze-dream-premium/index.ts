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
    const { step = "questions", dreamText, emotion, locale, answers } = await req.json();

    if (!dreamText || dreamText.trim().length < 10) {
      return new Response(
        JSON.stringify({ error: "Dream text too short" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const isTr = locale === "tr";

    if (step === "questions") {
      const systemPrompt = `You are a world-class dream analyst preparing a Deep Premium Dream Analysis.

YOUR CORE PRINCIPLE:
The dreamer wrote their dream because they want to understand what it MEANS.
NEVER ask about emotions, feelings, or real-life connections. Instead, ask about MISSING SCENE DETAILS from the dream itself — concrete facts about what happened, what they saw, who was there, what changed.

STEP 1 — VALIDATION:
If the text is clearly NOT a dream (random spam, gibberish, daily news, jokes), set "is_valid_dream" to false and return empty questions.

STEP 2 — SCENE ANALYSIS:
Identify missing information and ambiguous elements in the narrative.

STEP 3 — DETERMINE QUESTION COUNT:
Count questions based on complexity: 1 to 4 questions max.

STEP 4 — EXACT QUESTION FORMAT (CRITICAL for gpt-4o-mini):
The UI ONLY has 3 buttons: [Yes], [No], [Not Sure]. Any question that cannot be answered by clicking one of these is a COMPLETE FAILURE.

DO NOT write "Do you remember X" or "What was X" or "Who was X". YOU MUST GUESS a detail and ask if your guess is correct.

BAD vs GOOD EXAMPLES:
BAD (Open-ended): "Kedinin rengi neydi?" (User answers 'Yes' -> You still don't know the color)
GOOD (Guessing): "Kedi simsiyah mıydı?" (User answers 'Yes' -> You know the color)

BAD (Open-ended): "Ormanda kimi gördün?"
GOOD (Guessing): "Ormanda gördüğün kişi tanıdık biri miydi?"

BAD (Open-ended): "Kafes düştüğünde ne yaptın?"
GOOD (Guessing): "Kafes düştükten sonra kaçmaya çalıştın mı?"

BAD ("Or" Choice): "İçeride karanlık mıydı yoksa aydınlık mı?"
GOOD (Single truth): "İçerisi tamamen karanlık mıydı?"

ABSOLUTE RULES:
1. NO OPEN-ENDED QUESTIONS! NEVER use Kim, Ne, Nasıl, Neden, Niye, Nerede, Hangi, Ne kadar, Kaç, Neydi, Kimdi.
2. NO "A or B" QUESTIONS! NEVER use "yoksa", "veya", "ya da".
3. NO "Do you remember" questions! NEVER use "hatırlıyor musun", "fark ettin mi".
4. Ask in ${isTr ? "Turkish" : "English"}. TR questions MUST end with a Yes/No particle ("mu?", "mı?", "mısın?", "mıydın?", "mıydı?").
5. MINIMUM QUESTION LENGTH: Every question MUST be at least 6 words long. Ultra-short questions like "Güneş doğrudan mı?" or "Hava soğuk muydu?" are BANNED — they are too vague and meaningless.
6. Every question must contain CONTEXT from the dream. Good: "Rüyada oturduğun sakin yerdeki rüzgar yüzüne doğru mu esiyordu?" — Bad: "Rüzgar var mıydı?"

Return JSON:
{
  "is_valid_dream": boolean,
  "questions": [
    { "id": "q1", "question": "... MUST be a true Yes/No question!" }
  ]
}`;

      const userPrompt = `Dream:\n"${dreamText}"`;

      const response = await fetch(OPENAI_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model: MODEL,
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userPrompt },
          ],
          temperature: 0.3,
        }),
      });

      if (!response.ok) {
        throw new Error(`OpenAI HTTP error: ${response.status}`);
      }

      const data = await response.json();
      const resultText = data.choices[0]?.message?.content || "{}";
      let parsed = JSON.parse(resultText);

      // Post-processing to ENFORCE Yes/No format programmatically
      if (parsed.questions && Array.isArray(parsed.questions)) {
        parsed.questions = parsed.questions.map((q: any) => {
          if (typeof q.question === "string") {
            let text: string = q.question;

            // Remove ", yoksa..." and ", veya..." parts
            text = text.replace(/,?\s*(yoksa|veya)\s+[^?]+\?/i, "?");
            text = text.replace(/\?+/g, "?");

            // Check for forbidden open-ended words (Turkish-safe boundaries)
            const rx = /(^|\s)(kim|nasıl|neden|niye|hangi|ne kadar|kaç|ne|kimler)(\s|$|[.?,!])/i;
            if (rx.test(text)) {
              text = "Rüyandaki sahnede, detayını tam veremediğin ama senin için önemli hissettiren bir şey var mıydı?";
            }

            q.question = text;
          }
          return q;
        });
      }

      return new Response(JSON.stringify(parsed), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });

    } else if (step === "analyze") {
      // answers format: [{ "questionId": "q1", "question": "...", "answer": "yes/no/unsure" }]
      const safeAnswers = answers || [];

      // Build answers context string
      let answersContext = "";
      if (safeAnswers.length > 0) {
        answersContext = safeAnswers.map((a: any) =>
          `Q: ${a.question}\nA: ${a.answer}`
        ).join("\n\n");
      }

      const systemPrompt = `You are an elite dream psychoanalyst (Jungian + Freudian + neuroscience). Perform a PREMIUM DEEP ANALYSIS.

${answersContext ? `DREAMER'S ANSWERS:\n${answersContext}\n\n"Yes" = confirm detail, analyze significance. "No" = ABSENT, analyze what absence reveals. "Unsure" = liminal/unconscious element.\n` : ""}

RULES: Ground claims in psychology/neuroscience. Reference brain regions (amygdala, hippocampus, prefrontal cortex, DMN, insular cortex, ventral striatum). Use Jung archetypes (Shadow, Anima/Animus, Self, Persona). Match dream's ACTUAL tone — don't force negativity on peaceful dreams. Write in ${isTr ? 'Turkish "sen" form, NEVER "siz"' : 'English'}. BANNED: "gösteriyor", "yansıtıyor", "ifade ediyor", "içsel çatışma", "bilinçaltı", "bastırılmış duygular", "temsil eder". Use visceral metaphors, not academic language.

Return ONLY valid JSON:
{
  "title": "3-5 word poetic title",
  "subconscious_map": {
    "zones": [{"name": "Zone name", "symbol": "Dream element", "description": "1 sentence"}],
    "journey_type": "separation_initiation_return|descent_transformation_ascent|pursuit_confrontation_resolution|fragmentation_integration|loop_trapped",
    "journey_label": "Label",
    "summary": "2 sentences"
  },
  "archetype": {
    "primary": "Dominant Jungian archetype",
    "emoji": "1 emoji",
    "description": "2-3 sentences, SPECIFIC to dream content",
    "shadow_note": "1 sentence on shadow side"
  },
  "symbols": [{"name": "Symbol", "core_meaning": "1 sentence", "cultural_context": "1 sentence", "personal_reflection": "1 clinical sentence, ~15 words"}],
  "timeline": [{"scene": 1, "title": "Title", "description": "What happens", "psychological_shift": "1 clinical sentence, ~15 words"}],
  "clarifying_insights": [{"question_id": "q1", "why_asked": "1 sentence", "insight": "1 sharp sentence on their answer"}],
  "shadow_self": {
    "revealed": "1 piercing sentence using 'Sen'",
    "answer_insight": "1-2 sentences synthesizing ALL answers combined",
    "integration_hint": "1 actionable sentence"
  },
  "emotional_layers": {
    "surface": {"emotion": "Name", "explanation": "1 sentence"},
    "middle": {"emotion": "Name", "explanation": "1 sentence"},
    "deep": {"emotion": "Name", "explanation": "1 sentence"},
    "synthesis": "1-2 punchy sentences"
  },
  "brain_science": {
    "primary_region": "Brain region name",
    "primary_region_emoji": "🧠",
    "mechanism": "1 sentence with neuroscience terms",
    "fascinating_fact": "1 fact starting with '${isTr ? 'Bilimsel Gerçek' : 'Scientific Fact'}:'"
  },
  "recurring_pattern": {
    "detected": true,
    "pattern_name": "Striking 2-3 word label",
    "description": "1 sentence on waking life habit/loop",
    "resolution_hint": "1 actionable sentence"
  },
  "ritual": {
    "title": "2-3 word ritual name",
    "action": "1-2 concrete sentences",
    "emoji": "🕯️",
    "science_note": "1 sentence on WHY it works"
  },
  "reflection_question": "3-4 sentence clinical VERDICT (NOT a question) about WHY they had this dream. State as fact. NEVER use 'belki/muhtemelen/olabilir/veya'. Be shockingly specific about a real-life trigger. Vary opening style.",
  "reflection_responses": {
    "absolutely": "2 sentences. Personalized therapeutic technique referencing THIS dream's elements.",
    "maybe": "2 sentences. Self-observation task using THIS dream's symbols.",
    "not_sure": "2 sentences. Mindfulness exercise anchored in THIS dream's imagery."
  },
  "cosmic_closing": "2-3 line poetic closing using dream-specific imagery",
  "waking_life_deduction": {
    "suspected_trigger": "2-4 word label of real event",
    "cause_and_effect": "2 sentences deducing REAL waking-life event. No symbol interpretation. NEVER use 'gösteriyor/temsil ediyor/simge'."
  },
  "distribution": {
    "emotional_load": {"value": 75, "reasoning": "1 sentence + brain region. Values must sum to 100."},
    "uncertainty": {"value": 60, "reasoning": "1 sentence + brain region"},
    "recent_memory_effect": {"value": 40, "reasoning": "1 sentence + brain region"},
    "brain_activity": {"value": 25, "reasoning": "1 sentence + brain region"}
  }
}

Generate 2-3 symbols, 2-4 scenes, 2-3 zones. Distribution values MUST sum to 100. Every field unique — no redundancy. cosmic_closing uses dream imagery. answer_insight synthesizes ALL answers.`;

      const emotion_str = emotion || "not specified";
      const userPrompt = `Deep premium analysis. Dream: "${dreamText}" | Emotion: ${emotion_str}${answersContext ? ` | Answers:\n${answersContext}` : ""}`;

      const response = await fetch(OPENAI_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model: MODEL,
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userPrompt },
          ],
          temperature: 0.6,
          max_tokens: 2200,
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        console.error("OpenAI error:", response.status, errText);
        throw new Error(`OpenAI HTTP error: ${response.status}`);
      }

      const data = await response.json();
      const rawContent = data.choices?.[0]?.message?.content;

      if (!rawContent) {
        throw new Error("Empty AI response");
      }

      let parsed = JSON.parse(rawContent);

      // Post-processing: siz → sen fix for Turkish
      if (isTr) {
        const fixSen = (obj: any): any => {
          if (typeof obj === "string") {
            return obj
              .replace(/Rüyanız/g, "Rüyan").replace(/rüyanız/g, "rüyan")
              .replace(/yaşadığınız/g, "yaşadığın").replace(/hissettiğiniz/g, "hissettiğin")
              .replace(/olmanız/g, "olman").replace(/kalmanız/g, "kalman")
              .replace(/beyniniz/g, "beynin").replace(/hayatınız/g, "hayatın")
              .replace(/bilinçaltınız/g, "bilinçaltın").replace(/Bilinçaltınız/g, "Bilinçaltın")
              .replace(/kendiniz/g, "kendin").replace(/düşünceleriniz/g, "düşüncelerin")
              .replace(/duygularınız/g, "duyguların").replace(/ilişkileriniz/g, "ilişkilerin")
              .replace(/sorularınız/g, "soruların").replace(/cevaplarınız/g, "cevapların")
              .replace(/zihinsel/g, "zihinsel"); // keep as-is
          }
          if (Array.isArray(obj)) return obj.map(fixSen);
          if (obj && typeof obj === "object") {
            const result: any = {};
            for (const [k, v] of Object.entries(obj)) {
              result[k] = fixSen(v);
            }
            return result;
          }
          return obj;
        };
        parsed = fixSen(parsed);
      }

      return new Response(JSON.stringify(parsed), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } else {
      throw new Error("Invalid step parameter.");
    }
  } catch (err: any) {
    console.error("Error in analyze-dream-premium:", err.message);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
