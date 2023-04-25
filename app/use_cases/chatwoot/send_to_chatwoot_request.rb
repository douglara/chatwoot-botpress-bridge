require 'faraday'

class Chatwoot::SendToChatwootRequest < Micro::Case
  attributes :account_id
  attributes :conversation_id
  attribute :body

  attributes :chatwoot_endpoint
  attributes :chatwoot_bot_token

  def call!
    url = "#{chatwoot_endpoint}/api/v1/accounts/#{account_id}/conversations/#{conversation_id}/messages"

    response = Faraday.post(url, body.to_json, 
      {'Content-Type': 'application/json', 'api_access_token': "#{chatwoot_bot_token}"}
    )

    Rails.logger.info("Chatwoot response")
    Rails.logger.info("Status code: #{response.status}")
    Rails.logger.info("Body: #{response.body}")

    if (response.status == 200)
      Success result: JSON.parse(response.body)
    elsif (response.status == 404 && response.body.include?('Resource could not be found') )
      Failure result: { message: 'Chatwoot resource could not be found' }
    elsif (response.status == 404)
      Failure result: { message: 'Invalid chatwoot endpoint' }
    elsif (response.status == 401)
      Failure result: { message: 'Invalid chatwoot access token' }
    else
      Failure result: { message: 'Chatwoot server error' }
    end
  end
end