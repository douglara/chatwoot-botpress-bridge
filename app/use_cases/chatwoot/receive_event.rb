require 'faraday'

class Chatwoot::ReceiveEvent < Micro::Case
  attributes :event

  def call!
    process_event(event)
  end

  def valid_event?(event)
    event['event'] == 'message_created' && event['message_type'] == 'incoming' && event['conversation']['status'] == 'pending'
  end

  def process_event(event)
    if valid_event?(event)
      account_id = event['account']['id']
      conversation_id = event['conversation']['id']
      botpress_endpoint = event['botpress_endpoint'] || ENV['BOTPRESS_ENDPOINT']
      botpress_bot_id = event['botpress_bot_id'] || ENV['BOTPRESS_BOT_ID']
      chatwoot_endpoint = event['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
      chatwoot_bot_token = event['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']

      botpress_responses = Chatwoot::SendToBotpress.call(event: event, botpress_endpoint: botpress_endpoint, botpress_bot_id: botpress_bot_id)
      botpress_responses.data['responses'].each do | response |
        result = Chatwoot::SendToChatwoot.call(account_id: account_id, conversation_id: conversation_id, content: response['text'], chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token)
        if result.failure?
          Failure result: { message: 'Error send to chatwoot' }
        end
      end

      Success result: botpress_responses.data
    else
      Failure result: { message: 'Invalid event' }
    end
  end
end