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
    const { step = "questions", dreamText, locale } = await req.json();

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
The dreamer wrote their dream because they want to understand what it MEANS — what their subconscious is telling them. They do NOT know how they feel — that is YOUR job to figure out. 
Therefore, NEVER ask about emotions, feelings, or real-life connections. Instead, ask about MISSING SCENE DETAILS from the dream itself — concrete facts about what happened, what they saw, who was there, what changed — details they forgot to mention or didn't think were important, but that would dramatically change the analysis.

STEP 1 — VALIDATION:
If the text is clearly NOT a dream (random spam, gibberish, daily news, jokes), set "is_valid_dream" to false and return empty questions.

STEP 2 — SCENE ANALYSIS (internal, do NOT output):
Read the dream carefully and identify:
a) KEY MOMENTS where the scene shifts or something important happens
b) MISSING INFORMATION — what details are absent that would change the interpretation?
c) AMBIGUOUS ELEMENTS — things that could mean very different things depending on one detail
d) SENSORY GAPS — sounds, colors, weather, light, time of day not mentioned

STEP 3 — DETERMINE QUESTION COUNT:
Count the questions based on the dream's complexity:
• 1 question  → Dream is short (1-2 sentences), single scene, very specific. Only one critical detail is missing.
• 2 questions → Dream is moderate length, has 1-2 scenes, a few notable gaps in the narrative.
• 3 questions → Dream has multiple scenes or a scene transition, several characters, or important ambiguous moments.
• 4 questions → Dream is long and complex with many characters, multiple scene changes, and several ambiguous/missing elements.

Factors that INCREASE question count:
- More people/characters mentioned → ask about their behavior or identity
- Scene transitions (place A → place B) → ask about the transition
- Vague descriptions ("bir yer", "birisi") → ask for specifics
- Strong actions (falling, running, flying) → ask about physical details during those moments

Factors that DECREASE question count:
- Dream is already very detailed with sensory descriptions
- Single scene with clear narrative
- Few characters

STEP 4 — QUESTION GENERATION:
Generate the determined number of questions about the DREAM'S CONTENT. Each question must:
• Ask about a SPECIFIC missing detail from a SPECIFIC moment in the dream
• Be something the dreamer might have experienced in the dream but didn't mention
• Have a Yes/No/Unsure answer that would genuinely SHIFT the analysis direction
• Feel like a brilliant detective noticing what was left unsaid

QUESTION EXAMPLES (mix types):
1. SENSORY / ATMOSPHERE:
   TR: "Olay olurken etrafta hiç ses duydun mu?" / EN: "Did you hear any sound while that happened?"
2. MISSING DETAILS / ACTIONS:
   TR: "Kafes düştükten sonra onu kurtarmaya çalıştın mı?" / EN: "Did you try to save him after the cage fell?"
3. IDENTITY / RECOGNITION:
   TR: "O kişiyi gerçek hayattan tanıyor muydun?" / EN: "Did you recognize that person from real life?"
4. PERSPECTIVE / STATE:
   TR: "Kendini dışarıdan izler gibi mi gördün?" / EN: "Did you watch yourself from the outside?"

ABSOLUTE RULES (CRITICAL):
1. The UI ONLY has 3 buttons: [Yes], [No], [Not Sure]. Any question that cannot be answered by clicking one of these is a FAILURE.
2. NO OPEN-ENDED QUESTIONS:
   - EN: NEVER use Who, What, When, Where, Why, How, How much.
   - TR: ASLA "Kim", "Ne", "Nasıl", "Neden", "Niye", "Nerede", "Hangi", "Ne kadar", "Kaç" sorma!
3. NO "A or B" QUESTIONS:
   - EN: NEVER use "or" in the question.
   - TR: ASLA soruda "yoksa", "veya", "ya da" kullanma!
4. NEVER ask about FEELINGS or REAL LIFE connections.
5. Ask ONLY about concrete dream scene details.
6. Keep questions short — 1 sentence max.
7. DIVERSITY: Each question must ask about a DIFFERENT type of missing detail.
8. NEVER copy the example questions. You MUST write completely original questions specific to THIS dream.

Write questions in ${isTr ? 'Turkish, using informal "sen" form. TR DİKKAT: Kullanıcının klavyesi YOK! SADECE "Evet", "Hayır" ya da "Emin değilim" butonlarına basabilir. Sorularını KESİNLİKLE sadece bu üçünden biriyle cevaplanabilecek şekilde SADELEŞTİR!' : 'English. EN WARNING: User has no keyboard, only Yes/No/Unsure buttons. Questions MUST be answerable with those 3 buttons!'}
CRITICAL: Every Turkish question MUST end with a Yes/No particle ("mu?", "mı?", "mısın?", "mıydın?", "mü?", "müydü?"). If a sentence contains "yoksa", "veya", "ne kadar", "kim", "nasıl", YOU FAIL.

Return JSON:
{
  "is_valid_dream": boolean,
  "questions": [
    { "id": "q1", "question": "... MUST be a true Yes/No question, NO 'yoksa' inside!" }
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
      // Stub for subsequent implementation of detailed Premium card answers
      return new Response(JSON.stringify({ success: true, message: "Premium Analysis is pending." }), {
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
