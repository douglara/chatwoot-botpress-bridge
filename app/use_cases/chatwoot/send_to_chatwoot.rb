require 'faraday'

class Chatwoot::SendToChatwoot < Micro::Case
  attributes :event
  attribute :botpress_response

  def call!
    account_id = event['account']['id']
    conversation_id = event['conversation']['id']
    chatwoot_endpoint = event['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
    chatwoot_bot_token = event['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']

    if botpress_response_choise_options?(botpress_response)
      return Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id, 
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: build_choise_options_body(botpress_response)
      )
    elsif botpress_response_dropdown?(botpress_response)
      return Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id, 
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: build_dropdown_body(botpress_response)
      )
    else
      return Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id, 
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: { content: botpress_response['text'] }
      )
    end
  end

  def botpress_response_choise_options?(botpress_response)
    botpress_response['type'] == 'single-choice'
  end

  def build_choise_options_body(botpress_response)
    { content: botpress_response['text'], content_type: 'input_select', content_attributes: { type: 'button', items: botpress_response['choices'].map { | option | { title: option['title'], value:  option['value'] } } }  }
  end

  def botpress_response_dropdown?(botpress_response)
    botpress_response['type'] == 'dropdown'
  end

  def build_dropdown_body(botpress_response)
    { content: botpress_response['placeholderText'], description: botpress_response['message'], content_type: 'input_select', content_attributes: { type: 'list', items: botpress_response['options'].map { | option | { title: option['label'], value:  option['label'], description: option['value'] } } }  }
  end
end