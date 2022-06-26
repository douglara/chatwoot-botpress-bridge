require "test_helper"

class ChatwootControllerTest < ActionDispatch::IntegrationTest
  test "success" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Testing","markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post,  Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":64374,"content":"Testing","inbox_id":10,"conversation_id":11791,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656268790,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    body = File.read(Rails.root.to_s + "/test/fixtures/files/new_message.json")
    post chatwoot_webhook_url, params: body, headers: { "Content-Type": "application/json" }
    assert_response :success
  end
end
