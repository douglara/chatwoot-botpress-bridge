require 'faraday'

class Chatwoot::ReceiveEvent
  def self.call(event)
    process_event(event)
  end

  def self.valid_event?(event)
    event['event'] == 'message_created' && event['message_type'] == 'incoming' && event['conversation']['status'] == 'pending'
  end

  def self.process_event(event)
    if valid_event?(event)
      account_id = event['account']['id']
      conversation_id = event['conversation']['id']
      botpress_responses = Chatwoot::SendToBotpress.call(event)
      botpress_responses['responses'].each do | response |
        Chatwoot::SendToChatwoot.call(account_id, conversation_id, response['text'])
      end
      return { ok: botpress_responses }
    else
      return { error: 'Invalid request' }
    end
  end
end