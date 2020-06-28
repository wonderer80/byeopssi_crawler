require 'json'
require_relative './byeopssi_crawler.rb'

def lambda_handler(event:, context:)
  send_update_message
  { statusCode: 200, body: JSON.generate('success!') }
end
