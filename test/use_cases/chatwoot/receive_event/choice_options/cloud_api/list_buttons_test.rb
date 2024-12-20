require "test_helper"

class ListButtonsTest < ActionDispatch::IntegrationTest
  setup do
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_message/cloud_api_buttons.json"))
    @inbox_json = File.read(Rails.root.to_s + "/test/fixtures/files/inbox_with_buttons.json")
  end

  test "success with list buttons" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Opção 1","value":"Sim"},{"title":"Opção 2","value":"Não"},{"title":"Opção 3","value":"Não"},{"title":"Opção 4","value":"Não"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"554196910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSQ0IwOEMxOThDNTJBQzExNEY0AA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "success with list buttons with description" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Opção 1 <Descrição do botão>","value":"Sim"},{"title":"Opção 2","value":"Não"},{"title":"Opção 3","value":"Não"},{"title":"Opção 4","value":"Não"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"554196910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSRTRBNDkwRTMxOTg1OURGMEQ1AA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "should send list button description text greater than allowed" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Opção 1 <Large descrption............................................................>","value":"Sim"},{"title":"Opção 2","value":"Não"},{"title":"Opção 3","value":"Não"},{"title":"Opção 4","value":"Não"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"554196910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSQjA1OEVBM0JEMTJENkMwQUYyAA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "should send list button text greater than allowed" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Large button..............","value":"Sim"},{"title":"Opção 2","value":"Não"},{"title":"Opção 3","value":"Não"},{"title":"Opção 4","value":"Não"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"*Mary Assistente Virtual:*\n\nOie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"554196910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSRUU5NDdEQUQ2MjRCNDVFNEU3AA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end

  test "invalid event" do
    result = Flow::Run.call(chatwoot_webhook: {})
    assert_equal true, result.failure?
  end
end
