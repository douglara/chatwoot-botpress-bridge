require 'faraday'

class Chatwoot::SendToChatwoot
  def self.call(account_id, conversation_id, content)
    url = "#{ENV['CHATWOOT_ENDPOINT']}/api/v1/accounts/#{account_id}/conversations/#{conversation_id}/messages"

    body = {
      'content': content
    }

    response = Faraday.post(url, body.to_json, 
      {'Content-Type': 'application/json', 'api_access_token': "#{ENV['CHATWOOT_BOT_TOKEN']}"}
    )
  end
end