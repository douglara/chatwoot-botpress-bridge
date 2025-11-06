require "test_helper"

class Botpress::Api::CloudClientTest < ActionDispatch::IntegrationTest
  setup do
    @botpress_get_or_create_response = File.read(Rails.root.to_s + "/test/fixtures/botpress/cloud/api/conversation/get_or_create_response.json")
    @botpress_endpoint = ENV['BOTPRESS_ENDPOINT']
    @path = '/conversations/sssssssssssssssssssdddddddd/messages'
    @request_kind = 'get'
    @request_body = {}
  end

  test "success" do
    stub_request(:get, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: @botpress_get_or_create_response, headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Botpress::Api::CloudClient.call(botpress_endpoint: @botpress_endpoint, path: @path, request_kind: @request_kind , request_body: @request_body)

    assert result.success?
    assert_equal JSON.parse(@botpress_get_or_create_response), result.data
  end

  class Failed < Botpress::Api::CloudClientTest
    test 'when webhook token is invalid' do
      stub_request(:get, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
      to_return(status: 200, body: { "id": "err_20251106055013x71215316", "code": 404, "type": "ResourceNotFound", "message": "[Webhook Handler] Integration with webhook ID \"ss\" not found" }.to_json, headers: {'Content-Type': 'application/json; charset=utf-8'})

      result = Botpress::Api::CloudClient.call(botpress_endpoint: @botpress_endpoint, path: @path, request_kind: @request_kind , request_body: @request_body)

      assert result.failure?
      assert_equal "Invalid botpress cloud webhook token", result.data[:message]
    end

    test 'when its authentication error' do
      stub_request(:get, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
      to_return(status: 401, body: { "id": "err_20251106055510x5668068A", "code": 401, "type": "Unauthorized", "message": "Invalid user key" }.to_json, headers: {'Content-Type': 'application/json; charset=utf-8'})

      result = Botpress::Api::CloudClient.call(botpress_endpoint: @botpress_endpoint, path: @path, request_kind: @request_kind , request_body: @request_body)

      assert result.failure?
      assert_equal "Invalid botpress cloud user token", result.data[:message]
    end

    test 'when its generic error' do
      stub_request(:get, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
      to_return(status: 403, body: { error: "erro" }.to_json, headers: {'Content-Type': 'application/json; charset=utf-8'})

      result = Botpress::Api::CloudClient.call(botpress_endpoint: @botpress_endpoint, path: @path, request_kind: @request_kind , request_body: @request_body)

      assert result.failure?
      assert_equal "Invalid botpress endpoint", result.data[:message]
    end
  end
end
