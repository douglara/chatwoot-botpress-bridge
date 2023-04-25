require "test_helper"

class ButtonsBodyTest < ActionDispatch::IntegrationTest
  setup do
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_message_buttons.json"))
    @inbox_json = File.read(Rails.root.to_s + "/test/fixtures/files/inbox_with_buttons.json")
  end

  test "valid buttons" do
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"5541996910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSQTk2QUU1NkZBNTNBRjAzQzhBAA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    phone_number_id = '101695376189278'
    token = 'EAAMnWm7EWGwBAF9EXsGAR6LxjFRgAaScM3VcpXuATRoiGChafyVvrUThpmoVic6eSrg3JiIiv3nebUaZBIRe6CwWI56Uy8jvx2iEgEMXawQBTYTixr19kHZA3MZA6e4ZA1VLdkMtXGnIkbZBpBbIXfAtK5wOwmV8MrpPfVEXJqQ9tNWuC2dW8'
    to = '5541996910256'
    botpress_response = JSON.parse('{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Sim","value":"Sim"},{"title":"Não","value":"Não"}],"markdown":true,"typing":true}')
    result = Chatwoot::CloudApi::Buttons.call(phone_number_id: phone_number_id, token: token, to: to, botpress_response: botpress_response)
    assert_equal true, result.success?
    body_actions = '{"buttons":[{"type":"reply","reply":{"id":"option_0","title":"Sim"}},{"type":"reply","reply":{"id":"option_1","title":"Não"}}]}'
    result_body_actions = result[:body][:interactive][:action].to_json.to_s
    assert_equal body_actions, result_body_actions
  end

  test "should send button greater than allowed" do
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 200, body: '{"messaging_product":"whatsapp","contacts":[{"input":"5541996910256","wa_id":"554196910256"}],"messages":[{"id":"wamid.HBgMNTU0MTk2OTEwMjU2FQIAERgSQTk2QUU1NkZBNTNBRjAzQzhBAA=="}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    phone_number_id = '101695376189278'
    token = 'EAAMnWm7EWGwBAF9EXsGAR6LxjFRgAaScM3VcpXuATRoiGChafyVvrUThpmoVic6eSrg3JiIiv3nebUaZBIRe6CwWI56Uy8jvx2iEgEMXawQBTYTixr19kHZA3MZA6e4ZA1VLdkMtXGnIkbZBpBbIXfAtK5wOwmV8MrpPfVEXJqQ9tNWuC2dW8'
    to = '5541996910256'
    botpress_response = JSON.parse('{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[{"title":"Large button..............","value":"Sim"},{"title":"Não","value":"Não"},{"title":"Status","value":"Status"}],"markdown":true,"typing":true}')
    result = Chatwoot::CloudApi::Buttons.call(phone_number_id: phone_number_id, token: token, to: to, botpress_response: botpress_response)
    assert_equal true, result.success?
    body_actions = '{"buttons":[{"type":"reply","reply":{"id":"option_0","title":"Large button........"}},{"type":"reply","reply":{"id":"option_1","title":"Não"}},{"type":"reply","reply":{"id":"option_2","title":"Status"}}]}'
    result_body_actions = result[:body][:interactive][:action].to_json.to_s
    assert_equal body_actions, result_body_actions
  end

  test "should error with no buttons" do
    stub_request(:post, 'https://graph.facebook.com/v16.0/101695376189278/messages').
    to_return(status: 500, body: '{"error":{"message":"(#131009) Parameter value is not valid","type":"OAuthException","code":131009,"error_data":{"messaging_product":"whatsapp","details":"Invalid buttons count. Min allowed buttons: 1, Max allowed buttons: 3"},"fbtrace_id":"A-f5QU-ZzIztYQ6QAuziCFW"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    phone_number_id = '101695376189278'
    token = 'EAAMnWm7EWGwBAF9EXsGAR6LxjFRgAaScM3VcpXuATRoiGChafyVvrUThpmoVic6eSrg3JiIiv3nebUaZBIRe6CwWI56Uy8jvx2iEgEMXawQBTYTixr19kHZA3MZA6e4ZA1VLdkMtXGnIkbZBpBbIXfAtK5wOwmV8MrpPfVEXJqQ9tNWuC2dW8'
    to = '5541996910256'
    botpress_response = JSON.parse('{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1⃣ - Sim\n2⃣ - Não","dropdownPlaceholder":"Select...","choices":[],"markdown":true,"typing":true}')
    result = Chatwoot::CloudApi::Buttons.call(phone_number_id: phone_number_id, token: token, to: to, botpress_response: botpress_response)
    assert_equal false, result[:ok].present?
  end
end
