require "test_helper"

class SendToChatwootTest < ActionDispatch::IntegrationTest
  setup do
    @chatwoot_endpoint = ENV['CHATWOOT_ENDPOINT']
    @chatwoot_bot_token = ENV['CHATWOOT_BOT_TOKEN']

    @account_id = '1'
    @conversation_id = '11791'
    @content = 'Testing'

    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_message.json"))
    @botpress_response = {"type" => "text","workflow" => {},"text" => "Teste ok","markdown" => true,"typing" => true}
    @botpress_response_options = {"type"=>"single-choice", "skill"=>"choice", "workflow"=>{}, "text"=>"teste", "dropdownPlaceholder"=>"Select...", "choices"=>[{"title"=>"Opção 1", "value"=>"Opção 1"}, {"title"=>"Opção 2", "value"=>"Opção 2"}], "markdown"=>true, "typing"=>true}
  end

  test "success" do
    stub_request(:post, Regexp.new(@chatwoot_endpoint)).
    to_return(status: 200, body: '{"id":64325,"content":"Testing","inbox_id":10,"conversation_id":8524,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656186150,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    result = Chatwoot::SendToChatwoot.call(event: @event, botpress_response: @botpress_response)
    assert_equal true, result.success?
  end

  test "options response" do
    stub_request(:post, Regexp.new(@chatwoot_endpoint)).
    to_return(status: 200, body: '{"id":64325,"content":"Testing","inbox_id":10,"conversation_id":8524,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656186150,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    result = Chatwoot::SendToChatwoot.call(event: @event, botpress_response: @botpress_response_options)
    assert_equal true, result.success?
  end

  test "invalid endpoint" do
    stub_request(:post, /http/).
    to_return(status: 404)
    result = Chatwoot::SendToChatwoot.call(event: @event, botpress_response: @botpress_response)
    assert_equal true, result.failure?
    assert_equal 'Invalid chatwoot endpoint', result.data[:message]
  end
  
  test "invalid account id" do
    stub_request(:post, Regexp.new(@chatwoot_endpoint)).
    to_return(status: 404, body: '{"error":"Resource could not be found"}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    result = Chatwoot::SendToChatwoot.call(event: @event, botpress_response: @botpress_response)
    assert_equal true, result.failure?
    assert_equal 'Chatwoot resource could not be found', result.data[:message]
  end

  test "invalid conversation id" do
    stub_request(:post, Regexp.new(@chatwoot_endpoint)).
    to_return(status: 500, body: '{"status":500,"error":"Internal Server Error"}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    result = Chatwoot::SendToChatwoot.call(event: @event, botpress_response: @botpress_response)
    assert_equal true, result.failure?
    assert_equal 'Chatwoot server error', result.data[:message]
  end

  test "invalid content" do
    stub_request(:post, Regexp.new(@chatwoot_endpoint)).
    to_return(status: 200, body: '{"id":64370,"content":"{}","inbox_id":10,"conversation_id":11791,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656266542,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    result = Chatwoot::SendToChatwoot.call(event: @event, botpress_response: @botpress_response)
    assert_equal true, result.success?
  end

  test "invalid token" do
    stub_request(:post, Regexp.new(@chatwoot_endpoint)).
    to_return(status: 401)
    result = Chatwoot::SendToChatwoot.call(event: @event, botpress_response: @botpress_response)
    assert_equal true, result.failure?
    assert_equal 'Invalid chatwoot access token', result.data[:message]
  end
end
