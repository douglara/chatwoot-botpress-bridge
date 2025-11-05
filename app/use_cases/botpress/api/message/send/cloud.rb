require 'faraday'

class Botpress::Api::Message::Send::Cloud < Botpress::Api::Message::Send::Base
  def call!
    conversation_id = event['conversation']['id']
    body = build_body(conversation_id)

    get_or_create_conversation(conversation_id)

    request =  Botpress::Api::CloudClient.call(request_kind: 'post', botpress_endpoint:, path: "/messages", request_body: body)

    return Success(result: OpenStruct.new(data: { 'responses' => [] })) if request.success?

    request
  end

  private

  def get_or_create_conversation(conversation_id)
    Botpress::Api::Conversation::GetOrCreate::Cloud.call(botpress_endpoint:, conversation_id:)
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
    }.to_json
  end
end
