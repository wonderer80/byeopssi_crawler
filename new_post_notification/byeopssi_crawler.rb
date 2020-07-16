require 'open-uri'
require 'nokogiri'
require 'telegram/bot'
require 'aws-sdk-dynamodb'

def latest_posts
  url = 'http://byeopssi.kr/'
  doc = Nokogiri::HTML(URI.open("http://byeopssi.kr/sub.asp?mcd=family_story_open"))
  doc.xpath('//table/tbody/tr').map do |row|
    title = row.xpath("td[@class=\"subject\"]/a/div").children[2]
    next unless title

    title = title&.text&.strip

    author = row.xpath("td[@class=\"writer\"]/a/div").text

    post_link = row.xpath("td[@class=\"subject\"]/a")[0].attributes['href'].value

    link = url + post_link
    { title: title, author: author, link: link }
  end
end

def send_update_message
  token = ENV['token']

  Telegram::Bot::Client.run(token) do |bot|
    posts = latest_posts.compact
    posts[0..2].each do |post|
      result = search_post(post[:title])

      unless result
        text = "\"#{post[:author]}\" 님의 \"#{post[:title]}\" 게시물이 올라왔어요!\n#{post[:link]}"

        write_db(post[:title], post[:author])
        send_message_to_all_channel(text, bot)
      end
    end
  end
end

def write_db(title, author)
  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-2')
  table_name = ENV['byeopssi_table_name']

  params = {
      table_name: table_name,
      item: {
          type: 'post_notification',
          title: title,
          author: author,
          sended_at: Time.now.to_i
      }
  }

  dynamodb.put_item(params)
end

def search_post(title)
  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-2')
  table_name = ENV['byeopssi_table_name']

  params = {
      table_name: table_name,
      key: {
          title: title,
          type: 'post_notification'
      }
  }

  result = dynamodb.get_item(params)

  result.item
end

def regist_chat_id(chat_id)
  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-2')
  table_name = ENV['byeopssi_chat_ids_table_name']

  params = {
      table_name: table_name,
      item: {
          chat_id: chat_id,
          registed_at: Time.now.to_i
      }
  }

  dynamodb.put_item(params)
end

def send_message_to_all_channel(text, bot)
  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-2')
  table_name = ENV['byeopssi_chat_ids_table_name']

  params = {
      table_name: table_name,
      projection_expression: 'chat_id'
  }

  loop do
      result = dynamodb.scan(params)

      result.items.each do |item|
        chat_id = item['chat_id']
        next unless chat_id

        puts "chat_id: #{item['chat_id']}"

        begin
          bot.api.send_message(chat_id: chat_id, text: text)
        rescue  Aws::DynamoDB::Errors::ServiceError => error
          puts "Unable to scan:"
          puts "#{error.message}"
        rescue StandardError => error
          puts "Unknown error"
          puts "#{error.message}"
        end
      end

      break if result.last_evaluated_key.nil?

      puts "Scanning for more..."
      params[:exclusive_start_key] = result.last_evaluated_key
  end
end

