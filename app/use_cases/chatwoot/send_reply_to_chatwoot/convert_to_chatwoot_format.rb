require 'faraday'

class Chatwoot::SendReplyToChatwoot::ConvertToChatwootFormat < Micro::Case
  attributes :chatwoot_webhook,
  :account_id,
  :conversation_id,
  :chatwoot_endpoint,
  :chatwoot_bot_token,
  :buttons_active,
  :botpress_response

  def call!
    if botpress_response_choise_options?(botpress_response)
      return Chatwoot::SendReplyToChatwoot::ChoiceOptions::SendToChatwoot.call(event: chatwoot_webhook, botpress_response: botpress_response)
    else
      return handle_text
    end
  end

  def handle_text
    return Success result: { content: botpress_response['text'] }
  end

  def botpress_response_choise_options?(botpress_response)
    botpress_response['type'] == 'single-choice'
  end
end