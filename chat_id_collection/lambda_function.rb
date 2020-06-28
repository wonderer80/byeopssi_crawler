require 'json'
require_relative './chat_id_collector.rb'

def lambda_handler(event:, context:)
  puts event

  regist_chat_id(event)
  { statusCode: 200, body: JSON.generate('success!') }
end
