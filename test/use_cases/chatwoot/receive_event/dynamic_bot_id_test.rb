require "test_helper"

class DynamicBotIdTest < ActionDispatch::IntegrationTest
  setup do
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_messae_dynamic_bot_id.json"))
  end

  test "success" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Teste ok","markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":64372,"content":"Testing","inbox_id":10,"conversation_id":11791,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656268461,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Chatwoot::ReceiveEvent.call(event: @event)
    assert_equal true, result.success?
    assert_equal 'olx-principal', result.data[:botpress_bot_id]
  end
end
