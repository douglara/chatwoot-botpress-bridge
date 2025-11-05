class Botpress::Api::Conversation::GetOrCreate::Cloud < Micro::Case
  attributes :botpress_endpoint
  attributes :conversation_id

  def call!
    Botpress::Api::CloudClient.call(request_kind: 'post', botpress_endpoint:, path: "/conversations/get-or-create", request_body: build_body)
  end

  private

  def build_body
    {
      id: conversation_id
    }.to_json
  end
end
