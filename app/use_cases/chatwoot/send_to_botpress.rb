require 'faraday'

class Chatwoot::SendToBotpress
  def self.call(event)
    conversation_id = event['conversation']['id']
    message_content = event['content']
    url = "#{ENV['BOTPRESS_ENDPOINT']}/api/v1/bots/#{ENV['BOTPRESS_BOT_ID']}/converse/#{conversation_id}"

    body = {
      'text': "#{message_content}",
      'type': 'text',
      'metadata': {
        'event': event
      }
    }

    response = Faraday.post(url, body.to_json, {'Content-Type': 'application/json'})
    JSON.parse(response.body)
  end
end