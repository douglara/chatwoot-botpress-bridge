require 'faraday'

class Chatwoot::SendToChatwoot < Micro::Case
  attributes :event
  attribute :botpress_response

  def call!
    account_id = event['account']['id']
    conversation_id = event['conversation']['id']
    chatwoot_endpoint = event['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
    chatwoot_bot_token = event['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']

    if botpress_response_dropdown?(botpress_response)
      return Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id, 
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: build_dropdown_body(botpress_response)
      )

    elsif botpress_response_choise_options?(botpress_response)
      return Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id, 
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: build_choise_options_body(botpress_response)
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
    { 
      content: botpress_response['text'],
      template_params: { 
        'options': { 
          'useTemplateButtons': true,
          'buttons': botpress_response['choices'].map { | option | { 'text': option['title'], 'id': option['value'] } }
            }
       }
    }
  end

  def botpress_response_dropdown?(botpress_response)
    botpress_response['type'] == 'single-choice' && botpress_response['isDropdown'] == true
  end

  def build_dropdown_body(botpress_response)
    { 
      content: botpress_response['text'],
      template_params: {
        'buttonText': "#{botpress_response['dropdownPlaceholder']}",
        'description': "#{botpress_response['text']}",
        'sections': [{
          "rows": botpress_response['choices'].map { | option | { rowId: option['title'], title: option['title'], description: option['value'] } }
        }]
      }
    }
  end
end