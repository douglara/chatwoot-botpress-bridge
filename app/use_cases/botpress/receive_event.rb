class Botpress::ReceiveEvent < Micro::Case
  attributes :event

  def call!
    process_event(event)
  end

  def valid_event?(event)
    event['type'] == 'message_created' && event['data']['isBot'] == true
  end

  def process_event(event)
    if valid_event?(event)
      botpress_event_message = convert_to_botpress_self_hosted_response(event['data']['payload'])
      chatwoot_event = message_metadata

      chatwoot_responses = Chatwoot::SendToChatwoot.call(event: chatwoot_event, botpress_response: botpress_event_message)

      Failure result: { message: 'Error send to chatwoot' } if  chatwoot_responses.failure?

      Success result: { chatwoot_responses: chatwoot_responses }
    else
      Failure result: { message: 'Invalid event' }
    end
  end

  def message_metadata
    botpress_endpoint = event['botpress_endpoint'] || ENV['BOTPRESS_ENDPOINT']
    conversation_id = event['data']['conversationId']

    messages_list = Botpress::Api::Conversation::ListMessages::Cloud.call(
      botpress_endpoint: botpress_endpoint,
      conversation_id: conversation_id
    )

    messages_list["messages"].find { |msg| msg.dig("metadata") }&.dig("metadata", "event")
  end

  def convert_to_botpress_self_hosted_response(botpress_cloud_response)
    if botpress_cloud_response['type'] == 'choice'
        {
        "type" => "single-choice",
        "skill" => "choice",
        "workflow" => {},
        "text" => botpress_cloud_response['text'],
        "dropdownPlaceholder" => "Select...",
        "choices" => botpress_cloud_response['options'].map { |opt|
          { "title" => opt['label'], "value" => opt['value'] }
        },
        "markdown" => true,
        "typing" => true
      }
    else
      botpress_cloud_response
    end
  end
end
