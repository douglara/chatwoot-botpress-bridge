require 'faraday'

class Chatwoot::ReceiveEvent < Micro::Case
  attributes :event

  def call!
    process_event(event)
  end

  def valid_event?(event)
    event['event'] == 'message_created' && event['message_type'] == 'incoming' && valid_status?(event['conversation']['status'])
  end

  def valid_status?(status)
    if ENV['CHATWOOT_ALLOWED_STATUSES'].present?
      allowed_statuses = ENV['CHATWOOT_ALLOWED_STATUSES'].split(',')
    else
      allowed_statuses = %w[pending]
    end
    allowed_statuses.include?(status)
  end

  def process_event(event)
    if Chatwoot::ValidEvent.call(event: event).success?
      botpress_endpoint = event['botpress_endpoint'] || ENV['BOTPRESS_ENDPOINT']
      botpress_bot_id = Chatwoot::GetDynamicAttribute.call(event: event, attribute: 'botpress_bot_id').data[:attribute]

      botpress_responses = Chatwoot::SendToBotpress.call(
        event: event,
        botpress_endpoint: botpress_endpoint,
        botpress_bot_id: botpress_bot_id
      )
      chatwoot_responses = []
      botpress_responses.data['responses'].each do | response |
        result = Chatwoot::SendToChatwoot.call(event: event, botpress_response: response)
        chatwoot_responses << result.data

        if result.failure?
          Failure result: { message: 'Error send to chatwoot' }
        end

        sleep(ENV['CHATWOOT_MESSAGES_DELAY'].to_i) if ENV['CHATWOOT_MESSAGES_DELAY']
      end

      Success result: { botpress: botpress_responses.data , botpress_bot_id: botpress_bot_id, chatwoot_responses: chatwoot_responses }
    else
      Failure result: { message: 'Invalid event' }
    end
  end
end