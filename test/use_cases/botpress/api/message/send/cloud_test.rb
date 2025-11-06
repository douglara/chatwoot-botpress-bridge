require "test_helper"

class Botpress::Api::Message::Send::CloudTest < ActionDispatch::IntegrationTest
  setup do
    @event = { "conversation" => { "id" => "sssssssssssssssssssdddddddddd" }, "content" => "Olá" }
    @botpress_endpoint = ENV['BOTPRESS_ENDPOINT']
    @botpress_message_send_response = File.read(Rails.root.to_s + "/test/fixtures/botpress/cloud/api/message/send_response.json")
  end

  test "success" do
    stub_request(:get, /get-or-create/).
    to_return(status: 200, body: @botpress_get_or_create_response, headers: {'Content-Type': 'application/json; charset=utf-8'})

    stub_request(:post, /messages/).
    to_return(status: 200, body: @botpress_message_send_response, headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Botpress::Api::Message::Send::Cloud.call(event: @event, botpress_endpoint: @botpress_endpoint)
    assert result.success?
    assert_equal({ "responses" => [] }, result.data)
  end

  test "invalid" do
    stub_request(:get, /get-or-create/).
    to_return(status: 200, body: @botpress_get_or_create_response, headers: {'Content-Type': 'application/json; charset=utf-8'})

    stub_request(:post, /messages/).
    to_return(status: 404, body: {error: 'error message'}.to_json, headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Botpress::Api::Message::Send::Cloud.call(event: @event, botpress_endpoint: @botpress_endpoint)

    assert result.failure?
    assert_equal "Invalid botpress endpoint", result.data[:message]
  end
end
