require 'spaceship'

Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
  key_id: "U34JWT33YY",
  issuer_id: "c3a7ea4f-aa23-42dc-a462-655a17b0bbee",
  filepath: File.absolute_path("/Users/sdmgmz/crack-wish/AuthKey_U34JWT33YY.p8")
)

app = Spaceship::ConnectAPI::App.find("com.vlucky.vluckyFlutter")
puts "App found: #{app.name}"

