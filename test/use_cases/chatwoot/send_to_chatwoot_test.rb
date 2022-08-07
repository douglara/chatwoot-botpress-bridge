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
    @botpress_response_options = {"type"=>"text", "channel"=>"web", "direction"=>"incoming", "payload"=>{"type"=>"text", "text"=>"oi1"}, "target"=>"0c87efaa-ea34-46a5-819a-8851ad7b9b40", "botId"=>"nota-parana", "createdOn"=>"2022-08-07T14:55:31.179Z", "threadId"=>"cea789dc-bf04-45e6-b04f-ad38a2541bcf", "id"=>"6479532798567485156", "preview"=>"oi1", "flags"=>{}, "state"=>{"__stacktrace"=>[{"flow"=>"main.flow.json", "node"=>"entry"}, {"flow"=>"main.flow.json", "node"=>"choice-08a6e8"}], "user"=>{"timezone"=>-3, "language"=>"pt"}, "context"=>{"currentFlow"=>"skills/choice-08a6e8.flow.json", "currentNode"=>"parse", "previousFlow"=>"main.flow.json", "previousNode"=>"choice-08a6e8", "jumpPoints"=>[{"flow"=>"main.flow.json", "node"=>"choice-08a6e8"}], "queue"=>{"instructions"=>[{"type"=>"on-receive", "fn"=>"basic-skills/choice_parse_answer {\"randomId\":\"8ungs604w4\",\"contentId\":\"builtin_single-choice-u8MnqG\",\"invalidContentId\":\"\",\"keywords\":{\"Opção 1\":[\"Opção 1\"],\"Opção 2\":[\"Opção 2\"]},\"config\":{\"nbMaxRetries\":3,\"repeatChoicesOnInvalid\":false,\"variableName\":\"\"}}"}, {"type"=>"transition", "fn"=>"temp['skill-choice-valid-8ungs604w4'] === true", "node"=>"#"}, {"type"=>"transition", "fn"=>"true", "node"=>"invalid"}]}}, "session"=>{"lastMessages"=>[{"eventId"=>"6479532798567485156", "incomingPreview"=>"oi1", "replyConfidence"=>1, "replySource"=>"dialogManager", "replyDate"=>"2022-08-07T14:55:31.366Z", "replyPreview"=>"#!builtin_single-choice-u8MnqG"}], "workflows"=>{}, "slots"=>{}}, "temp"=>{}}, "messageId"=>"f9ac7548-07c0-48f4-a2ad-a26369e1ea09", "suggestions"=>[], "nlu"=>{"entities"=>[], "language"=>"en", "detectedLanguage"=>"sr", "spellChecked"=>"oi1", "ambiguous"=>false, "slots"=>{}, "intent"=>{"name"=>"none", "confidence"=>nil, "context"=>"global"}, "intents"=>[{"name"=>"none", "context"=>"global", "confidence"=>nil}], "errored"=>false, "includedContexts"=>["global"], "ms"=>43, "modelId"=>"ca783fe4b6bc9f36.b7f4a95061d75566.4832.en", "predictions"=>{}}, "processing"=>{"received"=>{"date"=>"2022-08-07T14:55:31.179Z"}, "stateLoaded"=>{"date"=>"2022-08-07T14:55:31.206Z"}, "hook:apply_nlu_contexts:completed"=>{"date"=>"2022-08-07T14:55:31.208Z"}, "mw:hitlnext.incoming:completed"=>{"date"=>"2022-08-07T14:55:31.209Z"}, "mw:hitl.captureInMessages:completed"=>{"date"=>"2022-08-07T14:55:31.248Z"}, "mw:nlu-predict.incoming:completed"=>{"date"=>"2022-08-07T14:55:31.295Z"}, "mw:qna.incoming:completed"=>{"date"=>"2022-08-07T14:55:31.295Z"}, "mw:analytics.incoming:completed"=>{"date"=>"2022-08-07T14:55:31.295Z"}, "mw:converse.capture.context:skipped"=>{"date"=>"2022-08-07T14:55:31.295Z"}, "hook:00_dialog_engine:completed"=>{"date"=>"2022-08-07T14:55:31.300Z"}, "hook:00_misunderstood_flag:completed"=>{"date"=>"2022-08-07T14:55:31.360Z"}, "hook:01_expire_nlu_contexts:completed"=>{"date"=>"2022-08-07T14:55:31.362Z"}, "hook:05_extract_slots:completed"=>{"date"=>"2022-08-07T14:55:31.366Z"}, "dialog:start"=>{"date"=>"2022-08-07T14:55:31.366Z"}, "completed"=>{"date"=>"2022-08-07T14:55:31.452Z"}}, "activeProcessing"=>{}, "decision"=>{"decision"=>{"reason"=>"no suggestion matched", "status"=>"elected"}, "confidence"=>1, "payloads"=>[], "source"=>"decisionEngine", "sourceDetails"=>"execute default flow"}}
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
