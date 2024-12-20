class Chatwoot::ProcessBotpressResponses < Micro::Case
  attributes :chatwoot_webhook
  attribute :botpress_responses

  def call!
    chatwoot_responses = []
    result = botpress_responses.data['responses'].each do | response |
      result = Chatwoot::SendReplyToChatwoot.call(chatwoot_webhook: chatwoot_webhook, botpress_response: response)
      if result.failure?
        Failure result: { message: 'Error send to chatwoot' }
      end
      chatwoot_responses << result.data
      sleep(ENV['CHATWOOT_MESSAGES_DELAY'].to_i) if ENV['CHATWOOT_MESSAGES_DELAY']
    end

    return Success result: { result: chatwoot_responses }
  end
end