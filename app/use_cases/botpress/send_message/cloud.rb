require 'faraday'

class Botpress::SendMessage::Cloud < Botpress::Send::Base
  inclde Botpress::Cloud::ResponseHandler

  def call!
    conversation_id = event['conversation']['id']
    url = "#{botpress_endpoint}/#{Botpress.cloud_wehook_token}/messages"
    body = build_body(conversation_id)

    get_or_create_conversation(conversation_id)

    response = Faraday.post(url, body.to_json, Botpress.cloud_request_headers)

    log_response_infos(response)

    body = JSON.parse(response.body)

    if success_response(response, body)
      Success result: OpenStruct.new(data: { 'responses' => [] })
    else
      Failure result: failed_response_message(response, body)
    end
  end

  private

  def get_or_create_conversation(conversation_id)
    Botpress::GetOrCreateConversation::Cloud.call(botpress_endpoint:, conversation_id:)
  end

  def build_body(conversation_id)
    message_content = event_message_content(event)

    {
      'payload': {
        'text': "#{message_content}",
        'type': 'text',
        'metadata': {
          'event': event
        }
      },
      "conversationId": "#{conversation_id}"
    }
  end
end
