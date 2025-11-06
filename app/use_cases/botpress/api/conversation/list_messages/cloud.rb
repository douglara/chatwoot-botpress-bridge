class Botpress::Api::Conversation::ListMessages::Cloud < Micro::Case
  attributes :botpress_endpoint
  attributes :conversation_id

  def call!
    request_params = "/conversations/#{conversation_id}/messages"

    Botpress::Api::CloudClient.call(request_kind: 'get', botpress_endpoint:, path: request_params, request_body: {})
  end
end
