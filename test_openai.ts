import { load } from "https://deno.land/std@0.208.0/dotenv/mod.ts";
const env = await load({ envPath: "/Users/sdmgmz/crack-wish/supabase/.env" });
const OPENAI_API_KEY = env["OPENAI_API_KEY"];

const response = await fetch("https://api.openai.com/v1/chat/completions", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${OPENAI_API_KEY}`
  },
  body: JSON.stringify({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a test." },
      { role: "user", content: "Hello" }
    ],
    max_completion_tokens: 300,
    response_format: { type: "json_object" }
  })
});

console.log(response.status);
console.log(await response.text());
