class Chatwoot::SendToBotpress < Micro::Case
  attributes :event
  attributes :botpress_endpoint
  attributes :botpress_bot_id

  def call!
    host_type = Botpress.host_type(botpress_endpoint)

    case host_type
    when :cloud
      Botpress::Api::Message::Send::Cloud.call(event:, botpress_endpoint:)
    when :self_hosted
      Botpress::Api::Message::Send::SelfHosted.call(event:, botpress_endpoint:, botpress_bot_id:)
    end
  end
end
