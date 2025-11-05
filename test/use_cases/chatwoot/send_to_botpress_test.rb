require "test_helper"

class Chatwoot::SendToBotpressTest < ActiveSupport::TestCase
  setup do
    @event = { "conversation" => { "id" => "123" }, "content" => "Oi" }
    @botpress_endpoint = "https://chat.botpress.cloud/d15a0a6c-d3be-419d-846a-240edbfe2646"
    @botpress_bot_id = "d15a0a6c-d3be-419d-846a-240edbfe2646"
  end

  test "calls Botpress::Cloud::Send when host_type is :cloud" do
    Botpress.stub(:host_type, :cloud) do
      mock = Minitest::Mock.new
      mock.expect(:call, true, [Hash])
      Botpress::Cloud::Send.stub(:call, mock) do
        Chatwoot::SendToBotpress.call(
          event: @event,
          botpress_endpoint: @botpress_endpoint,
          botpress_bot_id: @botpress_bot_id
        )
      end
      mock.verify
    end
  end

  test "calls Botpress::SelfHosted::Send when host_type is :self_hosted" do
    Botpress.stub(:host_type, :self_hosted) do
      mock = Minitest::Mock.new
      mock.expect(:call, true, [Hash])
      Botpress::SelfHosted::Send.stub(:call, mock) do
        Chatwoot::SendToBotpress.call(
          event: @event,
          botpress_endpoint: @botpress_endpoint,
          botpress_bot_id: @botpress_bot_id
        )
      end
      mock.verify
    end
  end
end
