require 'telegram/bot'
require 'aws-sdk-dynamodb'

def regist_chat_id(event)
  return unless event

  body =  JSON.parse(event['body'])
  token = ENV['token']
  chat_id = body['message']['chat']['id']
  title = body['message']['chat']['title']

  Telegram::Bot::Client.run(token) do |bot|
    next unless body['message']['text']
    if body['message']['text'] != '/start'
      bot.api.send_message(chat_id: chat_id, text: '죄송해요. 제가 잘 모르는 명령이에요ㅠㅠ')
      return
    end

    write_chat_id(chat_id, title)
    bot.api.send_message(chat_id: chat_id, text: '안녕하세요. 볍씨 알리미에요. 이제부터 제가 홈페이지에 글이 새로 올라오면 알려드릴께요. 현재는 볍씨가족 이야기(1) 에 올라오는 글만 알려드릴 수 있어요.')
  end
end

def write_chat_id(chat_id, title)
  return unless chat_id

  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-2')
  table_name = ENV['byeopssi_chat_ids_table_name']

  params = {
      table_name: table_name,
      item: {
          chat_id: chat_id.to_s,
          title: title,
          created_at: Time.now.to_i
      }
  }

  dynamodb.put_item(params)
end

