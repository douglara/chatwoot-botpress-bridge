require "test_helper"

class Chatwoot::SendToBotpressTest < ActiveSupport::TestCase
  setup do
    @event = { "conversation" => { "id" => "123" }, "content" => "Hi" }
    @botpress_endpoint = ENV['BOTPRESS_ENDPOINT']
    @botpress_bot_id = "d15a0a6c-d3be-419d-846a-240edbfe2646"
  end

  test "calls Botpress::Api::Message::Send::Cloud when host_type is :cloud" do
    skip "Mock problem"
    cloud_instance = Minitest::Mock.new
    cloud_instance.expect :call, Micro::Case::Result.new(success?: true)

    Botpress::Api::Message::Send::Cloud.stub :call, cloud_instance do
      result = Chatwoot::SendToBotpress.call(
        event: @event,
        botpress_endpoint: @botpress_endpoint,
        botpress_bot_id: @botpress_bot_id
      )

      assert result.success?
    end

    cloud_instance.verify
  end

  test "calls Botpress::Api::Message::Send::SelfHosted when host_type is :self_hosted" do
    skip "Mock problem"
    self_hosted_endpoint = "https://botpress.meusite.com"

    self_hosted_instance = Minitest::Mock.new
    self_hosted_instance.expect :call, Micro::Case::Result.new(success?: true)

    Botpress::Api::Message::Send::SelfHosted.stub :new, self_hosted_instance do
      result = Chatwoot::SendToBotpress.call(
        event: @event,
        botpress_endpoint: self_hosted_endpoint,
        botpress_bot_id: @botpress_bot_id
      )

      assert result.success?
    end

    self_hosted_instance.verify
  end
end
