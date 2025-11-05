require 'faraday'

class Botpress::ListMessages::Cloud < Micro::Case
  include Botpress::Cloud::ResponseHandler

  attributes :botpress_endpoint
  attributes :conversation_id

  def call!
    url = "#{botpress_endpoint}/#{Botpress.cloud_wehook_token}/#{conversation_id}/messages"

    response = Faraday.get(url, {}.to_json, Botpress.cloud_request_headers)

    body = JSON.parse(response.body)

    if success_response(response, body)
      Success result: JSON.parse(response.body)
    else
      Failure result: failed_response_message(response, body)
    end
  end
end
