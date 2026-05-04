const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL || 'YOUR_SUPABASE_URL';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY';
const supabase = createClient(supabaseUrl, supabaseKey);

async function testPush() {
  const { data, error } = await supabase.functions.invoke('push-notification', {
    body: {
      table: 'coffee_reading',
      record: {
        to_user: 'TEST_USER_ID', // we need a valid user id
        from_user: 'TEST_USER_ID',
        locale: 'tr'
      }
    }
  });

  console.log("Data:", data);
  console.log("Error:", error);
}

testPush();
