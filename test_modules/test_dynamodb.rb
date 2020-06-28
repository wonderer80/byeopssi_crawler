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
