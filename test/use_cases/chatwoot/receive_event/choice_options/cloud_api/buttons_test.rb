require "test_helper"

class ButtonsTest < ActionDispatch::IntegrationTest
  setup do
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_message/cloud_api_buttons.json"))
    @inbox_json = File.read(Rails.root.to_s + "/test/fixtures/files/inbox_with_buttons.json")
  end

  test "success with buttons" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Sim","value":"Sim"},{"title":"Não","value":"Não"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"554196910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSMEZERjkxNzM0Rjg0QTIyNkU5AA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "success with three buttons" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Sim","value":"Sim"},{"title":"Não","value":"Não"},{"title":"Status","value":"Status"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"554196910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSMEQ3NjM0NDQ0Q0IxQkRDQkFEAA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "should send button greater than allowed" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Large button..............","value":"Sim"},{"title":"Não","value":"Não"},{"title":"Status","value":"Status"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"554196910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSMDg5NEUxNjlCREQwRjk3RkNGAA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "should error with no buttons" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 500, body: '{"error":{"message":"(#131009) Parameter value is not valid","type":"OAuthException","code":131009,"error_data":{"messaging_product":"whatsapp","details":"Invalid buttons count. Min allowed buttons: 1, Max allowed buttons: 3"},"fbtrace_id":"A-f5QU-ZzIztYQ6QAuziCFW"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "invalid event" do
    result = Flow::Run.call(chatwoot_webhook: {})
    assert_equal true, result.failure?
  end
end
