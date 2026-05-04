import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"

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
    const { step = "questions", dreamText, emotion, locale, answers, userId } = await req.json();

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
5. MINIMUM QUESTION LENGTH: Every question MUST be at least 6 words long. Ultra-short questions like "Güneş doğrudan mı?" or "Hava soğuk muydu?" are BANNED.
6. Every question must contain CONTEXT from the dream. Good: "Rüyada oturduğun sakin yerdeki rüzgar yüzüne doğru mu esiyordu?"
7. NO TAUTOLOGICAL OR REDUNDANT QUESTIONS! Do NOT ask to confirm details the user already explicitly stated. (e.g., if they say "huge building", DO NOT ask "was it high?". If they say "relative", DO NOT ask "were they familiar?"). Instead, ask about a MISSING, PSYCHOLOGICALLY RELEVANT detail (e.g., "Did you feel a sense of relief while falling?").

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
        const fallbacks = [
          "Rüyandaki sahnede, detayını tam veremediğin ama senin için önemli hissettiren bir şey var mıydı?",
          "Bu rüya sırasında hissettiğin ama kelimelere dökemediğin gizli bir duygu var mıydı?",
          "Rüyanın genel atmosferinde seni huzursuz eden veya şaşırtan bir detay oldu mu?",
          "Rüyadaki olaylar sırasında kendi kararlarını kendin mi veriyordun?"
        ];
        let fallbackIndex = 0;

        parsed.questions = parsed.questions.map((q: any) => {
          if (typeof q.question === "string") {
            let text: string = q.question;

            // Remove ", yoksa..." and ", veya..." parts
            text = text.replace(/,?\s*(yoksa|veya)\s+[^?]+\?/i, "?");
            text = text.replace(/\?+/g, "?");

            // Check for forbidden open-ended words (Turkish-safe boundaries)
            const rx = /(^|\s)(kim|kimler|kimdi|nasıl|nasıldı|neden|niye|niçin|hangi|ne kadar|kaç|ne|neler|neydi|nerede|neresi|nereye|kimin)(\s|$|[.?,!'"])/i;
            if (rx.test(text)) {
              text = fallbacks[fallbackIndex % fallbacks.length];
              fallbackIndex++;
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

RULES: Ground claims in psychology/neuroscience. Reference brain regions (amygdala, hippocampus, prefrontal cortex, DMN, insular cortex, ventral striatum). Use Jung archetypes (Shadow, Anima/Animus, Self, Persona). Match dream's ACTUAL tone — don't force negativity on peaceful dreams. Ensure STRICT logical coherence in all cause-and-effect statements. If the emotion is "Belirsizlik", do NOT always default to "Kaygı"; explore nuances like transition, curiosity, or hidden potential. Write in ${isTr ? 'Turkish "sen" form, ALWAYS use correct possessive suffixes. ENSURE PERFECT SUBJECT-VERB AGREEMENT. NEVER write grammatically broken sentences like "Rüyandaki yağmur, temizlik sürecinden geçiyorsun." Instead, write correctly like "Rüyanda yağan yağmur, bir temizlik sürecinden geçtiğine dair bir his barındırıyor." NEVER "siz"' : 'English'}. BANNED: "gösteriyor", "yansıtıyor", "ifade ediyor", "içsel çatışma", "bilinçaltı", "bastırılmış duygular", "temsil eder". Use visceral metaphors, not academic language.

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
  "symbols": [{"name": "Symbol", "core_meaning": "1 sentence", "cultural_context": "1 sentence", "personal_reflection": "1 insightful sentence about this dreamer's waking life, ~15 words. NEVER start with 'Sen' or 'Senin için' — jump directly into the insight."}],
  "timeline": [{"scene": 1, "title": "Title", "description": "What happens", "psychological_shift": "1 soft, interpretive sentence (~15 words). Avoid strict definitive verbs like 'arttı' or 'azaldı'. Use noun phrases or soft endings (e.g., '...yüzeye çıkışı', '...hissi'). NEVER start with 'Sen'."}],
  "clarifying_insights": [{"question_id": "q1", "why_asked": "1 sentence", "insight": "1 sharp sentence on their answer. NEVER start with 'Sen'."}],
  "shadow_self": {
    "revealed": "1 piercing sentence about a HIDDEN aspect of self. Avoid claiming two synonymous things 'conflict' with each other. State the core issue directly without using the word 'çatışma' (conflict). NEVER start with 'Sen'.",
    "answer_insight": "1-2 sentences synthesizing the dreamer's real-life situation based on their answers. CRUCIAL: This MUST logically follow and AGREE with the 'revealed' sentence. Do NOT contradict the first sentence (e.g., if 'revealed' says they isolate themselves, do not say here they want to help people). Ensure perfect narrative continuity."
  },
  "emotional_layers": {
    "surface": {"emotion": "Name", "explanation": "1 sentence — the obvious feeling"},
    "middle": {"emotion": "Name", "explanation": "1 sentence — the hidden driver beneath the surface"},
    "deep": {"emotion": "Name", "explanation": "1 sentence — the root need or wound"},
    "synthesis": "1-2 punchy sentences connecting ALL THREE layers into a single psychological narrative. MUST differ from shadow_self and answer_insight."
  },
  "brain_science": {
    "primary_region": "Brain region name",
    "primary_region_emoji": "🧠",
    "mechanism": "EXACTLY 1 single sentence: HOW this brain region shaped the dream. NEVER write 2 sentences. NEVER repeat the same meaning twice (e.g. don't say 'Amygdala processes fear so fear deepened'). Be direct and sharp.",
    "fascinating_fact": "1 fact starting with '${isTr ? 'Bilimsel Gerçek' : 'Scientific Fact'}:'"
  },
  "recurring_pattern": {
    "detected": true,
    "pattern_name": "Striking 2-3 word label",
    "description": "1 sentence on waking life habit/loop"
  },
  "ritual": {
    "title": "2-3 word ritual name",
    "action": "1-2 concrete sentences",
    "emoji": "🕯️",
    "science_note": "1 sentence on WHY it works"
  },
  "reflection_question": "3-4 sentence gentle psychological REFLECTION (NOT a question) about what this dream might represent in their waking life. Do NOT sound like a doctor or give a clinical diagnosis. Use a supportive, exploratory tone.",
  "reflection_responses": {
    "absolutely": "2 sentences. Supportive self-reflection task referencing THIS dream's elements. (e.g. 'Rüyanda gördüğün X, Y hissini veriyor olabilir' NOT 'Rüyandaki X, Y yapıyorsun'). Do NOT prescribe therapy.",
    "maybe": "2 sentences. Gentle self-observation task using THIS dream's symbols. Ensure grammatically correct subject-verb agreement.",
    "not_sure": "2 sentences. Grounding mindfulness exercise anchored in THIS dream's imagery. Ensure grammatically correct subject-verb agreement."
  },
  "cosmic_closing": "2-3 line poetic closing using dream-specific imagery",
  "waking_life_deduction": {
    "suspected_trigger": "2-4 word label of real event",
    "cause_and_effect": "2 sentences deducing REAL waking-life event. No symbol interpretation. NEVER use 'gösteriyor/temsil ediyor/simge'."
  },
  "distribution": {
    "emotional_load": {"value": 75, "reasoning": "MAX 15 words. If value < 40, explain why emotions were LOW/CALM. If > 60, explain why they were HIGH/INTENSE."},
    "uncertainty": {"value": 60, "reasoning": "MAX 15 words. If value < 40, explain why narrative was LOGICAL/CLEAR. If > 60, explain why it was CHAOTIC."},
    "recent_memory_effect": {"value": 40, "reasoning": "MAX 15 words. If value < 40, explicitly state it is NOT connected to recent events. If > 60, state it IS connected."},
    "brain_activity": {"value": 25, "reasoning": "MAX 15 words. (This is AGENCY/CONTROL). If value < 40, state dreamer was PASSIVE. If > 60, state dreamer was ACTIVE."}
  }
}

Generate 2-3 symbols, 2-4 scenes, 2-3 zones. Each distribution value is an INDEPENDENT score from 0 to 100 (they do NOT need to sum to 100). cosmic_closing uses dream imagery. answer_insight synthesizes ALL answers.

ZERO-REDUNDANCY ENFORCEMENT (CRITICAL):
- distribution.reasoning = short score justification ("korku sahnesi yoğun olduğu için yüksek"). NEVER mention brain region function here.
- brain_science.mechanism = EXACTLY 1 sentence explaining brain-dream connection. NO repetitive tautologies (do not say A=B then B=A).
- shadow_self.revealed = hidden aspect of self. NEVER overlap with emotional_layers.synthesis.
- shadow_self.answer_insight = deduction from answers. Must flow naturally from 'revealed' and add real-life context. Do NOT create logical contradictions just to be different.
- emotional_layers.synthesis = emotional arc summary. NEVER copy shadow_self content.
- Each symbol's personal_reflection must be UNIQUE — never repeat core_meaning in different words.
- If ANY two fields would say the same thing, REWRITE one to convey a genuinely new insight.`;

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
          max_tokens: 2500,
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
            let s = obj;
            // Cümle başındaki "Sen,", "Senin için," gibi tekrarlayan gereksiz kelimeleri temizle
            const startPronounRegex = /^(Sen,|Senin için,|Senin için|Sen)\s+/i;
            if (startPronounRegex.test(s)) {
              s = s.replace(startPronounRegex, "");
              if (s.length > 0) s = s.charAt(0).toUpperCase() + s.slice(1);
            }
            return s
              .replace(/Rüyanız/g, "Rüyan").replace(/rüyanız/g, "rüyan")
              .replace(/yaşadığınız/g, "yaşadığın").replace(/hissettiğiniz/g, "hissettiğin")
              .replace(/olmanız/g, "olman").replace(/kalmanız/g, "kalman")
              .replace(/beyniniz/g, "beynin").replace(/hayatınız/g, "hayatın")
              .replace(/bilinçaltınız/g, "bilinçaltın").replace(/Bilinçaltınız/g, "Bilinçaltın")
              .replace(/kendiniz/g, "kendin").replace(/düşünceleriniz/g, "düşüncelerin")
              .replace(/duygularınız/g, "duyguların").replace(/ilişkileriniz/g, "ilişkilerin")
              .replace(/sorularınız/g, "soruların").replace(/cevaplarınız/g, "cevapların")
              .replace(/kendi korkularla/g, "kendi korkularınla")
              .replace(/kendi içsel korkularla/g, "kendi içsel korkularınla")
              .replace(/kendi düşüncelerle/g, "kendi düşüncelerinle")
              .replace(/kendi duygularla/g, "kendi duygularınla")
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

      // --- SEND PUSH NOTIFICATION ---
      try {
        if (userId) {
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
          console.log("Triggered push-notification for premium dream user", userId);
        }
      } catch(e) {
        console.error("FCM Error:", e);
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
