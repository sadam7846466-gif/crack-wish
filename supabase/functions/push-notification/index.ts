import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"
import admin from "npm:firebase-admin@11.11.1"

const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}');

if (!admin.apps.length && Object.keys(serviceAccount).length > 0) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

serve(async (req) => {
  try {
    const payload = await req.json();
    const record = payload.record;
    const tableName = payload.table; // Hangi tablodan tetiklendiğini anlar

    if (!record) return new Response("No record", { status: 400 });

    const toUserId = record.to_user;
    const fromUserId = record.from_user;

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    const { data: senderData } = await supabase.from('profiles').select('full_name').eq('id', fromUserId).single();
    const senderName = senderData?.full_name || 'Bir Arkadaş';

    const { data: receiverData } = await supabase.from('profiles').select('fcm_token').eq('id', toUserId).single();
    const fcmToken = receiverData?.fcm_token;

    if (!fcmToken) return new Response("No FCM token", { status: 200 });

    let title = "";
    let body = "";
    let sound = "default";
    let dataPayload = {};

    // Tabloya göre içeriği otomatik seç
    if (tableName === "owl_letters") {
        title = "Hoo Hoo! Yeni Bir Baykuş Mektubu Var 🦉";
        body = `${senderName} sana kozmik bir mesaj gönderdi. Hemen açıp oku!`;
        sound = "baykuszili.mp3";
        dataPayload = { type: "new_letter", letter_id: record.id };
    } else if (tableName === "friend_requests") {
        title = "Yeni Bir Kozmik Bağ! 🌌";
        body = `${senderName} seninle arkadaş olmak istiyor.`;
        sound = "default"; // Arkadaşlık isteklerinde normal telefon sesi çalar
        dataPayload = { type: "friend_request", request_id: record.id };
    } else {
        return new Response("Bilinmeyen tablo", { status: 200 });
    }

    // Bildirimi Firebase ile fırlat
    const response = await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: title,
        body: body
      },
      data: dataPayload,
      android: {
        notification: {
          sound: sound === "default" ? "default" : sound.replace('.mp3', '')
        }
      },
      apns: {
        payload: {
          aps: {
            sound: sound
          }
        }
      }
    });

    return new Response(JSON.stringify({ success: true, response }), { headers: { "Content-Type": "application/json" } });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 });
  }
})
