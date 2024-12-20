require 'faraday'

class Chatwoot::SendButtonsToCloudApi < Micro::Case
  attribute :chatwoot_endpoint
  attribute :account_id
  attribute :event
  attribute :botpress_response

  def call!
    inbox = get_inbox()
    phone_number_id = inbox['provider_config']['phone_number_id']
    token = inbox['provider_config']['api_key']
    to = event['conversation']['contact_inbox']['source_id']

    if (botpress_response['choices'].count) < 4
      response = Chatwoot::CloudApi::Buttons.call(phone_number_id: phone_number_id, token: token, to: to, botpress_response: botpress_response)[:response]
    else
      response = Chatwoot::CloudApi::ListButtons.call(phone_number_id: phone_number_id, token: token, to: to, botpress_response: botpress_response)[:response]
    end

    if response.status == 200
      return Success result: { content: "Enviado botões\n\n#{botpress_response['text']}", private: true }
    else
      Rails.logger.error("Error send buttons")
      Rails.logger.error("Meta response:")
      Rails.logger.error(response.body)
      Rails.logger.error("Event error:")
      Rails.logger.error(event)
      return Failure result: { content: "Erro no envio dos botões\n\n#{botpress_response['text']}", private: true }
    end
  end

  def get_inbox
    inbox_id = event['inbox']['id']
    chatwoot_admin_token = event['chatwoot_admin_token']
    url = "#{chatwoot_endpoint}/api/v1/accounts/#{account_id}/inboxes/#{inbox_id}"
    response = Faraday.get(url, nil, {'Content-Type': 'application/json', 'api_access_token': "#{chatwoot_admin_token}"})
    JSON.parse(response.body)
  end
end