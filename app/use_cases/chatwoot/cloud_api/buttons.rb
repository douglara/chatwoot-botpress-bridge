require 'faraday'

class Chatwoot::CloudApi::Buttons < Micro::Case
  attribute :phone_number_id
  attribute :token
  attribute :to
  attribute :botpress_response

  def call!
    url = "https://graph.facebook.com/v16.0/#{phone_number_id}/messages"
    body = build_body(botpress_response) 
    response = Faraday.post(
      url, 
      body.to_json,
      {'Content-Type': 'application/json', 'Authorization': "Bearer #{token}"}
    )
    return Success result: { body: JSON.parse(response.body), response: response, body_send: body }
  end

  def build_body(botpress_response)
    buttons = botpress_response['choices'].map.with_index do | option, index |
      {
        "type": "reply",
        "reply": {
          "id": "option_#{index}",
          "title": option['title'].truncate(20, :omission => "")
        }
      }
    end

    body = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": "interactive",
      "interactive": {
        "type": "button",
        "body": {
          "text": "#{botpress_response['text']}"
        },
        "action": {
          "buttons": buttons
        }
      }
    }
  end
end