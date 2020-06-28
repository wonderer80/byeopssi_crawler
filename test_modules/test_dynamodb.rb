require 'aws-sdk-dynamodb'

def write_db
  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-2')

  params = {
      table_name: 'byeopssi',
      item: {
          title: '게시글 제목',
          created_at: Time.now
      }
  }
  dynamodb.put_item(params)
end

def load_all_data
  dynamodb = Aws::DynamoDB::Client.new(region: 'ap-northeast-2')
  table_name = 'byeopssi_chat_ids'

  params = {
      table_name: table_name,
      projection_expression: 'chat_id'
  }

  begin
      loop do
          result = dynamodb.scan(params)

          result.items.each{|movie|
              puts "#{movie["year"].to_i}: " +
                       "#{movie["title"]} ... " +
                       "#{movie["info"]["rating"].to_f}"
          }

          break if result.last_evaluated_key.nil?

          puts "Scanning for more..."
          params[:exclusive_start_key] = result.last_evaluated_key
      end

  rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to scan:"
      puts "#{error.message}"
  end
end

