require "test_helper"

class SendToBotpressTest < ActionDispatch::IntegrationTest
  setup do
    @botpress_endpoint = ENV['BOTPRESS_ENDPOINT']
    @botpress_bot_id = ENV['BOTPRESS_BOT_ID']
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_message.json"))
  end

  test "valid event" do
    stub_request(:post, Regexp.new(@botpress_endpoint)).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Teste ok","markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    assert_equal true, Chatwoot::SendToBotpress.call(event: @event, botpress_endpoint: @botpress_endpoint, botpress_bot_id: @botpress_bot_id).success?
  end

  test "invalid event" do
    assert_raise(Exception) { Chatwoot::SendToBotpress.call(event: {}, botpress_endpoint: @botpress_endpoint, botpress_bot_id: @botpress_bot_id).success? }
  end

  test "invalid endpoint" do
    stub_request(:post, Regexp.new(@botpress_endpoint)).
    to_return(status: 404)
    result = Chatwoot::SendToBotpress.call(event: @event, botpress_endpoint: @botpress_endpoint, botpress_bot_id: @botpress_bot_id)
    assert_equal true, result.failure?
    assert_equal 'Invalid botpress endpoint', result.data[:message]
  end

  test "invalid bot" do
    stub_request(:post, Regexp.new(@botpress_endpoint)).
    to_return(status: 404, body: '{"statusCode":404,"errorCode":"BP_0044","type":"NotFoundError","message":"Not Found: Invalid Bot ID","details":"","docs":"https://botpress.com/docs"}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    result = Chatwoot::SendToBotpress.call(event: @event, botpress_endpoint: @botpress_endpoint, botpress_bot_id: @botpress_bot_id)
    assert_equal true, result.failure?
    assert_equal 'Invalid Bot ID', result.data[:message]
  end
end
