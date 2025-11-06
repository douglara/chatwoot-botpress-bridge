require "test_helper"

class Botpress::Api::Conversation::GetOrCreate::CloudTest < ActionDispatch::IntegrationTest
  setup do
    @botpress_get_or_create_response = File.read(Rails.root.to_s + "/test/fixtures/botpress/cloud/api/conversation/get_or_create_response.json")
    @botpress_endpoint = ENV['BOTPRESS_ENDPOINT']
  end

  test "success" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: @botpress_get_or_create_response, headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Botpress::Api::Conversation::GetOrCreate::Cloud.call(botpress_endpoint: @botpress_endpoint, conversation_id: 'sssssssssssssssssssdddddddddd')
    assert result.success?
    assert_equal JSON.parse(@botpress_get_or_create_response), result.data
  end
end
