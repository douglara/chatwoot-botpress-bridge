class Chatwoot::SendReplyToChatwoot < Micro::Case
  attributes :chatwoot_webhook
  attributes :botpress_response

  def call!
    @chatwoot_webhook = chatwoot_webhook
    @account_id = chatwoot_webhook['account']['id']
    @conversation_id = chatwoot_webhook['conversation']['id']
    @chatwoot_endpoint = chatwoot_webhook['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
    @chatwoot_bot_token = chatwoot_webhook['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']
    @buttons_active = chatwoot_webhook['active_buttons'].present?

    # Convert Botpress format to chatwoot
    chatwoot_response = Chatwoot::SendReplyToChatwoot::ConvertToChatwootFormat.call(
      chatwoot_webhook: @chatwoot_webhook,
      account_id: @account_id,
      conversation_id: @conversation_id,
      chatwoot_endpoint: @chatwoot_endpoint,
      chatwoot_bot_token: @chatwoot_bot_token,
      buttons_active: @buttons_active,
      botpress_response: botpress_response
    )

    # Send to Chatwoot   
    return Chatwoot::SendReplyToChatwoot::Request.call(
      account_id: @account_id, conversation_id: @conversation_id, 
      chatwoot_endpoint: @chatwoot_endpoint, chatwoot_bot_token: @chatwoot_bot_token,
      body: chatwoot_response.data
    )
  end
end