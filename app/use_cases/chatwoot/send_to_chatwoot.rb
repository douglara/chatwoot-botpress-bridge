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
    else
      return Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id, 
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: { content: botpress_response['content'] }
      )
    end
  end

  def botpress_response_choise_options?(botpress_response)
    botpress_response['state']['context']['queue']['instructions'][0]['fn'].present? rescue false
  end

  def build_choise_options_body(botpress_response)
    options_json = JSON.parse(botpress_response['state']['context']['queue']['instructions'][0]['fn'].split('choice_parse_answer ')[1])
    { content: botpress_response['content'], content_type: 'input_select', content_attributes: { items: options_json['keywords'].map { | option | { title: option[0], value:  option[1][0] } } }  }
  end
end