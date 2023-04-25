require 'faraday'

class Chatwoot::SendToChatwoot < Micro::Case
  attributes :event
  attribute :botpress_response

  def call!
    account_id = event['account']['id']
    conversation_id = event['conversation']['id']
    chatwoot_endpoint = event['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
    chatwoot_bot_token = event['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']
    buttons_active = event['active_buttons'].present?

    if buttons_active && inbox_is_whatsapp?(event) && botpress_response_choise_options?(botpress_response)
      if Chatwoot::SendButtonsToCloudApi.call(
          chatwoot_endpoint: chatwoot_endpoint,
          account_id: account_id,
          event: event,
          botpress_response: botpress_response
        ).success?
        return Chatwoot::SendToChatwootRequest.call(
          account_id: account_id, conversation_id: conversation_id, 
          chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
          body: { content: "Enviado botões\n\n#{botpress_response['text']}", private: true }
        )
      else
        return Chatwoot::SendToChatwootRequest.call(
          account_id: account_id, conversation_id: conversation_id, 
          chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
          body: { content: "Erro no envio dos botões\n\n#{botpress_response['text']}", private: true }
        )
      end
    else
      return Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id, 
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: { content: botpress_response['text'] }
      )
    end
  end

  def inbox_is_whatsapp?(event)
    event['conversation']['channel'] == 'Channel::Whatsapp'
  end

  def botpress_response_choise_options?(botpress_response)
    botpress_response['type'] == 'single-choice'
  end

  def build_choise_options_body(botpress_response)
    { content: botpress_response['text'], content_type: 'input_select', content_attributes: { items: botpress_response['choices'].map { | option | { title: option['title'], value:  option['value'] } } }  }
  end
end