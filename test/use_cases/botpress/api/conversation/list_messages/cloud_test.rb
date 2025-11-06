require "test_helper"

class Botpress::Api::Conversation::ListMessages::CloudTest < ActionDispatch::IntegrationTest
  setup do
    @botpress_list_messages_response = File.read(Rails.root.to_s + "/test/fixtures/botpress/cloud/api/conversation/list_messages_response.json")
    @botpress_endpoint = ENV['BOTPRESS_ENDPOINT']
  end

  test "success" do
    stub_request(:get, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: @botpress_list_messages_response, headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Botpress::Api::Conversation::ListMessages::Cloud.call(botpress_endpoint: @botpress_endpoint, conversation_id: '123456')
    assert result.success?
    assert_equal JSON.parse(@botpress_list_messages_response), result.data
  end

  test "invalid" do
    stub_request(:get, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 403, body: {"id":"err_20251106043504xCB639C57","code":403,"type":"Forbidden","message":"You are not a participant in this conversation"}.to_json, headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Botpress::Api::Conversation::ListMessages::Cloud.call(botpress_endpoint: @botpress_endpoint, conversation_id: '123456')
    assert result.failure?
    assert_equal "Invalid botpress endpoint", result.data[:message]
  end
end
