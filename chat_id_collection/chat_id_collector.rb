require 'telegram/bot'
require 'aws-sdk-dynamodb'

def regist_chat_id(event)
  return unless event

  body =  JSON.parse(event['body'])
  token = ENV['token']
  chat_id = body['message']['chat']['id']
  title = body['message']['chat']['title']

  Telegram::Bot::Client.run(token) do |bot|
    if body['message']['text'] != '/start'
      bot.api.send_message(chat_id: chat_id, text: '죄송해요. 제가 잘 모르는 명령이에요ㅠㅠ')
      return
    end

    write_chat_id(chat_id, title)
    bot.api.send_message(chat_id: chat_id, text: '알림이 등록되었습니다!')
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

