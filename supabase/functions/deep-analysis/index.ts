import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!;
const OPENAI_URL = "https://api.openai.com/v1/chat/completions";
const MODEL = "gpt-4o-mini";

// ─── ADIM 1: SORU ÜRETME ───
const QUESTION_SYSTEM_PROMPT = `Sen bilimsel bir rüya analistisin. Kullanıcının rüyasını daha derinlemesine analiz edebilmek için netleştirme soruları üreteceksin.

KURALLAR:
- Rüya metnini dikkatle oku
- Rüyanın içeriğine göre 2-4 soru üret (kısa rüya = 2 soru, detaylı rüya = 3-4 soru)
- Sorular rüyanın spesifik detaylarına yönelik olsun
- Her sorunun 2-3 seçeneği olsun
- Sorular bilimsel analizi derinleştirmek için olmalı
- Emoji KULLANMA

ÇIKTI FORMATI (JSON):
{
  "questions": [
    {
      "id": "q1",
      "question": "Soru metni",
      "options": [
        {"id": "a", "text": "Seçenek 1"},
        {"id": "b", "text": "Seçenek 2"},
        {"id": "c", "text": "Seçenek 3"}
      ]
    }
  ]
}

SORU ÖRNEKLERİ:
- "Rüyadaki [kişi/nesne] sana tanıdık mı geldi?" → Evet tanıdık / Hayır yabancıydı / Emin değilim
- "Rüyada ne hissediyordun?" → Kontrol edebiliyordum / Kontrolsüzdüm / İzliyordum
- "Bu sahne sana geçmişten bir anıyı hatırlattı mı?" → Evet / Hayır / Tam hatırlamıyorum`;

// ─── ADIM 2: DERİN ANALİZ ───
const DEEP_ANALYSIS_SYSTEM_PROMPT = `Sen dünya çapında bir rüya psikologu ve nörobilimcisin. Kullanıcının rüyasını, duygusunu ve sorulara verdiği cevapları kullanarak SON DERECE DERİN ve KİŞİSELLEŞTİRİLMİŞ bir analiz yapacaksın.

MUTLAK KURALLAR:
- Gelecek tahmini YAPMA, kader/din/mistisizm KULLANMA
- Bilimsel ve psikolojik temelli ol
- Kullanıcının sorulara verdiği cevapları analize entegre et
- Ciddi, profesyonel ama empatik ton kullan
- Emoji KULLANMA

ÇIKTI FORMATI (JSON):
{
  "sections": [
    {
      "title": "Bölüm başlığı",
      "icon": "brain|heart|shield|eye|link|lightbulb|warning|compass|layers|star",
      "content": "Bu bölümün detaylı içeriği. 2-4 cümle."
    }
  ],
  "metrics": [
    {
      "label": "Metrik adı",
      "value": 0-100 arası sayı,
      "description": "Kısa açıklama"
    }
  ],
  "title": "Rüya başlığı (3-5 kelime)",
  "symbols": ["Sembol 1", "Sembol 2"],
  "personalAdvice": "Kişiselleştirilmiş tavsiye. Rüya ve cevaplara göre özel. 3-5 cümle."
}

BÖLÜM KURALLARI:
- Rüyanın büyüklüğüne göre 4-8 bölüm oluştur
- Olası bölümler: Nörobilimsel Çerçeve, Duygusal Harita, Bilinçaltı Katmanları, Sembol Analizi, Stres ve Kontrol Haritası, Geçmiş Bağlantıları, Savunma Mekanizmaları, İlişkisel Dinamikler, Kişisel Gelişim Alanları
- Her bölüm derin, kişisel ve içgörü sağlayan olmalı

METRİK KURALLARI:
- 5-10 metrik oluştur
- Olası metrikler: Duygusal Yük, Belirsizlik, Yakın Geçmiş Etkisi, Beyin Aktivitesi, Stres, Kontrol Algısı, Nostalji, Güvenlik, Sosyal Bağlantı, Bilinçaltı Aktivitesi, Travma Etkisi, Yaratıcılık Düzeyi`;

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
    const { dreamText, emotion, locale, step, answers } = await req.json();

    if (!dreamText || dreamText.trim().length < 10) {
      return new Response(
        JSON.stringify({ error: "Dream text too short" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const isTr = locale === "tr";

    // ─── ADIM 1: SORU ÜRET ───
    if (step === "questions") {
      const userPrompt = isTr
        ? `RÜYA METNİ:\n${dreamText}\n\nDUYGU: ${emotion}\n\nBu rüya için netleştirme soruları üret. Türkçe yanıt ver.`
        : `DREAM TEXT:\n${dreamText}\n\nEMOTION: ${emotion}\n\nGenerate clarification questions for this dream. Respond in English.`;

      const response = await fetch(OPENAI_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model: MODEL,
          messages: [
            { role: "system", content: QUESTION_SYSTEM_PROMPT },
            { role: "user", content: userPrompt },
          ],
          temperature: 0.7,
          max_completion_tokens: 800,
          response_format: { type: "json_object" },
        }),
      });

      if (!response.ok) {
        return new Response(
          JSON.stringify({ error: "AI service unavailable" }),
          { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content;
      const parsed = JSON.parse(content);

      return new Response(JSON.stringify(parsed), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // ─── ADIM 2: DERİN ANALİZ ───
    if (step === "analyze") {
      const answersText = answers
        ?.map((a: { question: string; answer: string }) => `Soru: ${a.question}\nCevap: ${a.answer}`)
        .join("\n\n") || "Ek soru sorulmadı.";

      const userPrompt = isTr
        ? `RÜYA METNİ:\n${dreamText}\n\nDUYGU: ${emotion}\n\nNETLEŞTİRME CEVAPLARI:\n${answersText}\n\nBu rüyayı tüm bilgilerle birlikte derinlemesine analiz et. Türkçe yanıt ver.`
        : `DREAM TEXT:\n${dreamText}\n\nEMOTION: ${emotion}\n\nCLARIFICATION ANSWERS:\n${answersText}\n\nPerform a deep analysis using all information. Respond in English.`;

      const response = await fetch(OPENAI_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model: MODEL,
          messages: [
            { role: "system", content: DEEP_ANALYSIS_SYSTEM_PROMPT },
            { role: "user", content: userPrompt },
          ],
          temperature: 0.7,
          max_completion_tokens: 3000,
          response_format: { type: "json_object" },
        }),
      });

      if (!response.ok) {
        return new Response(
          JSON.stringify({ error: "AI service unavailable" }),
          { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content;
      const parsed = JSON.parse(content);

      return new Response(JSON.stringify(parsed), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({ error: "Invalid step. Use 'questions' or 'analyze'" }),
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
