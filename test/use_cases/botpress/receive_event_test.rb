require "test_helper"

class BotpressReceiveEventTest < ActionDispatch::IntegrationTest
  setup do
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/botpress/cloud/events/message/created.json"))
    @botpress_list_messages_response = File.read(Rails.root.to_s + "/test/fixtures/botpress/cloud/api/conversation/list_messages_response.json")
  end

  test "success" do
    stub_request(:get, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: @botpress_list_messages_response, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":64372,"content":"Testing","inbox_id":10,"conversation_id":11791,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656268461,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Botpress::ReceiveEvent.call(event: @event)
    assert result.success?
  end

  test "invalid event" do
    result = Botpress::ReceiveEvent.call(event: {})
    assert result.failure?
  end
end
