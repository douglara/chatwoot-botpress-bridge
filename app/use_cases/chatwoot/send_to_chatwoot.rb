class Chatwoot::SendToChatwoot < Micro::Case
  attributes :event
  attribute :botpress_response

  def call!
    account_id = event['account']['id']
    conversation_id = event['conversation']['id']
    chatwoot_endpoint = event['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
    chatwoot_bot_token = event['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']

    if response_image?(botpress_response) || response_file?(botpress_response) || response_video?(botpress_response)
      Chatwoot::SendFileToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id,
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        botpress_response: botpress_response
      )
    elsif response_choice_options?(botpress_response)
      Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id,
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: build_choice_options_body(botpress_response)
      )
    else
      Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id,
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: { content: botpress_response['text'] }
      )
    end
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

  def build_choice_options_body(botpress_response)
    {
      content: botpress_response['text'],
      content_type: 'input_select',
      content_attributes: {
        items: botpress_response['choices'].map {
          | option |
            {
              title: option['title'],
              value:  option['value']
            }
        }
      }
    }
  end
end