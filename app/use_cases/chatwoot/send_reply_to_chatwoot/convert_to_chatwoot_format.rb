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
    if response_image?(botpress_response) || response_file?(botpress_response) || response_video?(botpress_response)
      Chatwoot::SendFileToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id,
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        botpress_response: botpress_response
      )
    elsif botpress_response_choise_options?(botpress_response)
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

  def response_image?(response)
    response['type'] == 'image'
  end

  def response_file?(response)
    response['type'] == 'file'
  end

  def response_video?(response)
    response['type'] == 'video'
  end

  def response_choice_options?(response)
    response['type'] == 'single-choice'
  end
end