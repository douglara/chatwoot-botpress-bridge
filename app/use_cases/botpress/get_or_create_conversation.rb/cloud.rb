require 'faraday'

class Botpress::GetOrCreateConversation::Cloud < Micro::Case
  include Botpress::Cloud::ResponseHandler

  attributes :botpress_endpoint
  attributes :conversation_id

  def call!
    url = "#{botpress_endpoint}/#{Botpress.cloud_wehook_token}/conversations/get-or-create"

    response = Faraday.get(url, build_body.to_json, Botpress.cloud_request_headers)

    body = JSON.parse(response.body)

    if success_response(response, body)
      Success result: JSON.parse(response.body)
    else
      Failure result: failed_response_message(response, body)
    end
  end

  private

  def build_body
    {
      id: conversation_id
    }
  end
end
