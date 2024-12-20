require 'faraday'

class Flow::ProcessWebhook < Micro::Case
  attributes :chatwoot_webhook

  def call!
    process_event(chatwoot_webhook)
  end

  def process_event(chatwoot_webhook)
    botpress_endpoint = chatwoot_webhook['botpress_endpoint'] || ENV['BOTPRESS_ENDPOINT']
    botpress_bot_id = Chatwoot::GetDynamicAttribute.call(event: chatwoot_webhook, attribute: 'botpress_bot_id').data[:attribute]

    botpress_responses = Botpress::SendToBotpress.call(event: chatwoot_webhook, botpress_endpoint: botpress_endpoint, botpress_bot_id: botpress_bot_id)
    chatwoot_responses = Chatwoot::ProcessBotpressResponses.call(chatwoot_webhook: chatwoot_webhook, botpress_responses: botpress_responses)
    return Success result: {botpress: botpress_responses.data , botpress_bot_id: botpress_bot_id, chatwoot_responses: chatwoot_responses.data }
  end
end