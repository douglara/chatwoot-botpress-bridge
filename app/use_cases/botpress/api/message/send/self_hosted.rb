require 'faraday'

class Botpress::Api::Message::Send::SelfHosted < Botpress::Api::Message::Send::Base
  attributes :botpress_bot_id

  def call!
    conversation_id = event['conversation']['id']
    url = "#{botpress_endpoint}/api/v1/bots/#{botpress_bot_id}/converse/#{conversation_id}"
    body = build_body

    response = Faraday.post(url, body.to_json, {'Content-Type': 'application/json'})

    log_response_infos(response)

    if (response.status == 200)
      Success result: JSON.parse(response.body)
    elsif (response.status == 404 && response.body.include?('Invalid Bot ID'))
      Failure result: { message: 'Invalid Bot ID' }
    else
      Failure result: { message: 'Invalid botpress endpoint' }
    end
  end

  private

  def build_body
    message_content = event_message_content(event)
    {
      'text': "#{message_content}",
      'type': 'text',
      'metadata': {
        'event': event
      }
    }
  end
end
