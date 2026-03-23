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

QUESTION TYPES (mix different types):

1. MISSING ACTORS — Who else was there? Did someone appear/disappear?
   TR: "Kafesten çıktığında seni izleyen biri var mıydı?"
   EN: "Was there someone watching you when you climbed out of the cage?"

2. SENSORY DETAILS — Sounds, colors, light that were present
   TR: "Kafes düşerken etrafta bir ses duydun mu?"
   EN: "Did you hear any sound when the cage fell?"

3. ACTIONS NOT MENTIONED — Did they try something? Look back? Run?
   TR: "Kafes düştükten sonra geri dönüp onları kurtarmaya çalıştın mı?"
   EN: "After the cage fell, did you try to go back and save them?"

4. SCENE TRANSITIONS — Did scenes change suddenly?
   TR: "Ormana birden mi geldin, arası boş mu?"
   EN: "Did you suddenly find yourself in the forest with no transition?"

5. RECOGNITION & IDENTITY — Were people/places recognized?
   TR: "Kafesteki insanları gerçek hayattan tanıyor muydun?"
   EN: "Did you recognize the people in the cage from real life?"

6. PHYSICAL STATE — Body condition, injuries
   TR: "Kafesten çıktığında bedeninde bir acı var mıydı?"
   EN: "Did you feel any pain in your body when you got out of the cage?"

7. TIME & ATMOSPHERE — Day/night, weather
   TR: "Ormandaki ortam karanlık mıydı?"
   EN: "Was it dark in the forest?"

8. PERSPECTIVE — Was the dreamer watching from outside their body?
   TR: "Olayları dışarıdan, kendini izler gibi mi gördün?"
   EN: "Did you see the events from outside, as if watching yourself?"

9. MOVEMENT RESTRICTION — Did they struggle to move?
   TR: "Kafesten çıkarken zorlandın mı?"
   EN: "Did you struggle to get out of the cage?"

10. OTHERS' REACTIONS — What were other people doing?
    TR: "Kafesteki insanlar senden yardım istedi mi?"
    EN: "Did the people in the cage ask you for help?"

11. DREAM ENDING — Did the dream end at a specific moment?
    TR: "Rüya ormandayken mi bitti?"
    EN: "Did the dream end while you were in the forest?"

12. RECURRING DREAM — Has this happened before?
    TR: "Bu rüyayı ya da benzerini daha önce gördün mü?"
    EN: "Have you seen this dream or something similar before?"

13. EYE CONTACT — Did they lock eyes with someone?
    TR: "Kafes düşerken içerideki biriyle göz göze geldin mi?"
    EN: "Did you make eye contact with anyone inside the cage as it fell?"

14. DIRECTION OF MOVEMENT — Did they go up, down, or stay?
    TR: "Kafesten çıktıktan sonra yukarıya doğru mu gittin?"
    EN: "Did you go upward after getting out of the cage?"

ABSOLUTE RULES:
1. Questions MUST be answerable ONLY with "Yes" / "No" / "Not Sure".
2. NEVER ask about FEELINGS or EMOTIONS (no "korku hissettin mi?", "did you feel scared?").
3. NEVER ask about REAL LIFE connections (no "hayatında bunu temsil ediyor olabilir mi?").
4. NEVER ask open-ended questions (no Why/What/How/When/Where/Who).
5. NEVER ask "A or B" or "X mi yoksa Y mi?" questions. Every question must be ONE-DIRECTIONAL so the answer is unambiguous.
   BAD: "Kafesten çıkarken zorlandın mı, yoksa kolayca mı çıktın?" → "Evet" ne demek? Belirsiz!
   BAD: "Ormandaki ortam aydınlık mıydı yoksa karanlık mı?" → "Evet" ne demek? Belirsiz!
   BAD: "Bir ses duydun mu — çığlık mı metal sesi mi?" → İkili seçenek, yasak!
   GOOD: "Kafesten çıkarken zorlandın mı?" → Evet = zorlandım, Hayır = zorlanmadım ✓
   GOOD: "Ormandaki ortam karanlık mıydı?" → Evet = karanlıktı, Hayır = değildi ✓
   GOOD: "Kafes düşerken bir ses duydun mu?" → Evet = duydum, Hayır = duymadım ✓
6. Ask ONLY about concrete dream scene details — things that DID or DID NOT happen in the dream.
7. Each question should feel like a sharp detective who noticed exactly what's missing from the story.
8. Keep questions short — 1 sentence max.  
9. DIVERSITY: Each question must ask about a DIFFERENT type of missing detail.
10. NEVER copy the example questions above! They are ONLY to illustrate the question type. You MUST write completely original questions specific to THIS dream.
11. Pick the 2-4 question types that are MOST RELEVANT and would change the analysis the MOST for this particular dream. Do NOT randomly select types.

Write questions in ${isTr ? 'Turkish, using informal "sen" form. Keep it natural and conversational.' : 'English. Keep it natural and conversational.'}

Return JSON:
{
  "is_valid_dream": boolean,
  "questions": [
    { "id": "q1", "question": "..." }
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
          temperature: 0.85,
        }),
      });

      if (!response.ok) {
        throw new Error(`OpenAI HTTP error: ${response.status}`);
      }

      const data = await response.json();
      const resultText = data.choices[0]?.message?.content || "{}";
      const parsed = JSON.parse(resultText);

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
