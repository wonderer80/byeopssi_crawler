require 'telegram/bot'

token = ENV['token']

Telegram::Bot::Client.run(token) do |bot|
  bot.fetch_updates { puts }
  bot.listen do |message|
    case message.text
    when '/start'
      puts message.chat.id
      # bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/stop'
      # bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    end
  end
end
