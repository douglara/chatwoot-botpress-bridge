require 'faraday'

class Chatwoot::SendToBotpress < Micro::Case
  attributes :event
  attributes :botpress_endpoint
  attributes :botpress_bot_id

  def call!
    conversation_id = event['conversation']['id']
    message_content = event['content']
    url = "#{botpress_endpoint}/api/v1/bots/#{botpress_bot_id}/converse/#{conversation_id}"

    body = {
      'text': "#{message_content}",
      'type': 'text',
      'metadata': {
        'event': event
      }
    }

    response = Faraday.post(url, body.to_json, {'Content-Type': 'application/json'})

    Rails.logger.info("Botpress response")
    Rails.logger.info("Status code: #{response.status}")
    Rails.logger.info("Body: #{response.body}")

    if (response.status == 200)
      Success result: JSON.parse(response.body)
    elsif (response.status == 404 && response.body.include?('Invalid Bot ID'))
      Failure result: { message: 'Invalid Bot ID' }
    else
      Failure result: { message: 'Invalid botpress endpoint' }
    end
  end
end