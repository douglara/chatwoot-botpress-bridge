require 'faraday'

class Chatwoot::CloudApi::ListButtons < Micro::Case
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
    return Success result: { body: JSON.parse(response.body), response: response }
  end

  def get_list_button_text(choice_title)
    choice_without_description = choice_title.sub(/<.*?>/, '')
    choice_without_description.truncate(24, :omission => "")
  end

  def choice_title_have_description?(choice_title)
    choice_title.scan(/<.*?>/).size != 0
  end

  def get_list_button_description(choice_title)
    choice_title.scan(/<.*?>/)[0].sub(/</, '').sub(/>/, '').truncate(72, :omission => "")
  end

  def build_body(botpress_response)
    buttons = botpress_response['choices'].map.with_index do | option, index |
      btn = {
        "id": "option_#{index}",
        "title": get_list_button_text(option['title'])
      }

      btn.merge!({"description": get_list_button_description(option['title'])}) if choice_title_have_description?(option['title'])
      btn
    end

    body = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": "#{to}",
      "type": "interactive",
      "interactive": {
        "type": "list",
        "body": {
          "text": "#{botpress_response['text']}"
        },
        "action": {
          "button": "Selecionar opções",
          "sections": [
            {
              "title": "Opções",
              "rows": buttons
            }
          ]
        }
      }
    }
  end
end