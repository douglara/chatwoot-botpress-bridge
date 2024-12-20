require "test_helper"

class ChoicesOptionsConvertToTextTest < ActionDispatch::IntegrationTest
  setup do
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_message.json"))
    #@inbox_json = File.read(Rails.root.to_s + "/test/fixtures/files/inbox_with_buttons.json")
  end

  test "should convert to text" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Oie, seja bem vindo(a) novamente a central de atendimento da *SoftPower*","markdown":true,"typing":true},{"type":"single-choice","skill":"choice","workflow":{},"text":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?","dropdownPlaceholder":"Select...","choices":[{"title":"Sim","value":"Sim"},{"title":"Não","value":"Não"}],"markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":1082331,"content":"Em nosso último atendimento falamos sobre a empresa *DLOUGLAS LARA* eseja seguir com o cadastro?\n\n1 - Sim\n2 - Não","inbox_id":143,"conversation_id":20484,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1676259394,"private":false,"source_id":null,"sender":{"id":26,"name":"Mary Assistente Virtual","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    #stub_request(:get, Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    #to_return(status: 200, body: @inbox_json, headers: {'Content-Type': 'application/json; charset=utf-8'})

    result = Flow::Run.call(chatwoot_webhook: @event)
    assert_equal true, result.success?
  end
end
