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
4. Ask in ${isTr ? "Turkish" : "English"}. TR questions MUST end with a Yes/No particle ("mu?", "mı?", "mısın?", "mıydın?").

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

      const systemPrompt = `You are a world-class dream psychoanalyst combining Jungian depth psychology, Freudian psychodynamics, and modern neuroscience. You are performing a PREMIUM DEEP ANALYSIS — this is NOT a quick interpretation. This is the equivalent of a 1-hour therapy session distilled into a structured report.

YOUR MISSION: Reveal what the dreamer's subconscious is REALLY saying. Show them patterns they cannot see. Make them feel genuinely understood and surprised by the depth of insight.

The dreamer has already answered clarifying Yes/No questions about their dream. Use those answers to DEEPEN your analysis — they reveal what the dreamer noticed vs. what they missed.

${answersContext ? `
DREAMER'S ANSWERS TO CLARIFYING QUESTIONS:
${answersContext}

CRITICAL: These answers are GOLD. A "Yes" confirms a detail exists in the dream — analyze its psychological significance. A "No" means the detail was ABSENT — analyze what that absence reveals (often more telling than presence). An "Unsure" indicates a liminal/unconscious element — this is where the deepest material hides.
` : ""}

SCIENTIFIC RIGOR RULES:
- Ground EVERY claim in established psychological or neuroscientific theory
- Reference specific brain regions (amygdala, hippocampus, prefrontal cortex, default mode network) when relevant
- Use REM sleep science, memory consolidation theory, threat simulation theory
- Cite Jungian archetypes by their proper names (Shadow, Anima/Animus, Self, Persona, Trickster, Great Mother, Wise Old Man)
- Apply Freudian concepts where appropriate (displacement, condensation, wish fulfillment, day residue)
- NEVER predict the future or use mystical language
- Be psychologically precise but accessible — like a brilliant professor explaining to a curious student

TONE: Intelligent, warm, scientifically grounded, occasionally poetic. Use "sen" form in Turkish. Make the dreamer feel like they're being truly SEEN.

Write in ${isTr ? 'Turkish. Use informal "sen" form, NEVER "siz". Write naturally, not like a textbook translation.' : 'English.'}

Return ONLY valid JSON with this EXACT structure:

{
  "title": "A poetic but grounded 3-5 word title for this dream's core theme",

  "subconscious_map": {
    "zones": [
      { "name": "Zone name (e.g. Safe Harbor, Transition Zone, Unknown Territory)", "symbol": "The dream element representing this zone", "description": "1-2 sentences on psychological meaning" }
    ],
    "journey_type": "One of: separation_initiation_return | descent_transformation_ascent | pursuit_confrontation_resolution | fragmentation_integration | loop_trapped",
    "journey_label": "Human-readable label for the journey type",
    "summary": "2-3 sentences describing the overall psychological geography of this dream"
  },

  "archetype": {
    "primary": "The dominant Jungian archetype active in this dream",
    "emoji": "A single emoji representing this archetype",
    "description": "3-4 sentences on how this archetype manifests in the dream. Be SPECIFIC to dream content, not generic.",
    "shadow_note": "1-2 sentences on the shadow side of this archetype — what the dreamer might be avoiding or suppressing"
  },

  "symbols": [
    {
      "name": "Symbol name from the dream",
      "core_meaning": "1 sentence — the psychological core meaning",
      "cultural_context": "1 sentence — universal/cultural significance",
      "personal_reflection": "1-2 sentences — what this means specifically for THIS dreamer based on context and answers"
    }
  ],

  "timeline": [
    {
      "scene": 1,
      "title": "Short scene title",
      "description": "What happens in this scene",
      "psychological_shift": "What changes psychologically at this point"
    }
  ],

  "shadow_self": {
    "revealed": "2-3 sentences on what the dreamer's Shadow (suppressed self) is showing in this dream",
    "answer_insight": "1-2 sentences on what the Yes/No answers specifically reveal about the dreamer's relationship with their Shadow. If no answers, write about what the dream imagery itself reveals.",
    "integration_hint": "1 sentence — a gentle suggestion for Shadow integration"
  },

  "emotional_layers": {
    "surface": { "emotion": "The obvious/surface emotion", "explanation": "1 sentence" },
    "middle": { "emotion": "The emotion beneath the surface", "explanation": "1 sentence" },
    "deep": { "emotion": "The deepest, often unconscious emotion", "explanation": "1 sentence" },
    "synthesis": "2-3 sentences weaving all three layers together into a coherent emotional narrative"
  },

  "brain_science": {
    "primary_region": "The most active brain region (e.g. amygdala, hippocampus, prefrontal cortex, default mode network)",
    "primary_region_emoji": "🧠 or relevant emoji",
    "mechanism": "2-3 sentences explaining WHAT the brain was doing during this dream and WHY, using specific neuroscience (REM, memory consolidation, threat simulation, emotional processing)",
    "fascinating_fact": "1 surprising neuroscience fact relevant to this specific dream that will make the dreamer go 'wow'"
  },

  "recurring_pattern": {
    "detected": true or false,
    "pattern_name": "Name of the pattern (e.g. 'Escape Loop', 'Authority Confrontation', 'Identity Search')",
    "description": "2-3 sentences on what this pattern means if it recurs, and what unresolved issue it points to. Even if not explicitly recurring, identify the ARCHETYPE of dream this belongs to.",
    "resolution_hint": "1 sentence on how to work with this pattern"
  },

  "ritual": {
    "title": "A specific, actionable ritual name",
    "action": "2-3 sentences describing exactly what to do. Must be concrete, doable tonight/tomorrow. Not vague spiritual advice.",
    "emoji": "🕯️ or relevant emoji",
    "science_note": "1 sentence on WHY this works (neuroplasticity, memory reconsolidation, etc.)"
  },

  "cosmic_closing": "A 2-4 line poetic closing message. Short lines. Like the best Tarot closings — haunting, personal, memorable. Use dream-specific imagery. This should give chills.",

  "distribution": {
    "emotional_load": { "value": number (0-100), "reasoning": "1 sentence on why this specific dream got this emotional load score based on amygdala/emotional activity" },
    "uncertainty": { "value": number (0-100), "reasoning": "1 sentence on why this specific dream got this uncertainty score based on logical breaks or transitions" },
    "recent_memory_effect": { "value": number (0-100), "reasoning": "1 sentence on why this specific dream got this recent memory score based on day residue/hippocampus" },
    "brain_activity": { "value": number (0-100), "reasoning": "1 sentence on why this specific dream got this agency/control score based on prefrontal cortex activity" }
  }
}

CRITICAL QUALITY RULES:
1. Generate exactly 2-3 symbols in the "symbols" array
2. Generate exactly 2-4 scenes in the "timeline" array (based on dream complexity)
3. Generate exactly 2-3 zones in the "subconscious_map.zones" array
4. Distribution percentages MUST sum to 100
5. EVERY section must reference SPECIFIC elements from THIS dream — NO generic psychology
6. The cosmic_closing must use imagery FROM the dream, not generic metaphors
7. If the dreamer answered questions, the shadow_self.answer_insight MUST reference specific answers
8. Keep the total output comprehensive but focused — quality over quantity`;

      const emotion_str = emotion || "not specified";
      const userPrompt = `Perform a deep premium analysis of this dream.

Dream text:
"${dreamText}"

Selected waking emotion: ${emotion_str}

${answersContext ? `The dreamer answered these clarifying questions:
${answersContext}` : "No clarifying questions were asked."}

Generate the complete deep analysis JSON.`;

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
          temperature: 0.5,
          max_completion_tokens: 3000,
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
