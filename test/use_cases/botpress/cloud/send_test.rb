require "test_helper"

class Botpress::Cloud::SendTest < ActionDispatch::IntegrationTest
  setup do
    @event = load_event('new_message.json')
    @botpress_endpoint = ENV['BOTPRESS_ENDPOINT']
    @botpress_bot_id = ENV['BOTPRESS_BOT_ID']

    @request_options = {
      body: {
        'text': 'teste 1',
        'type': 'text',
        'metadata': { 'event': @event }
      }
    }
  end

  test "valid event with content and no attachments" do
    stub_request(:post, Regexp.new(@botpress_endpoint))
      .with(@request_options)
      .to_return(
        status: 200,
        body: '{"responses":[{"type":"text","workflow":{},"text":"Teste ok","markdown":true,"typing":true}]}'
      )

    assert send_to_botpress_call.success?
  end

  test "valid event without content but with an attachment" do
    @event = load_event('new_message_with_no_content_and_with_attachment.json')

    @request_options = {
      body: {
        'text': '/image',
        'type': 'text',
        'metadata': { 'event': @event }
      }
    }

    stub_request(:post, Regexp.new(@botpress_endpoint))
      .with(@request_options)
      .to_return(
        status: 200,
        body: '{"responses":[{"type":"text","workflow":{},"text":"Teste ok","markdown":true,"typing":true}]}'
      )

    assert send_to_botpress_call.success?
  end

  test "invalid event" do
    @event = {}

    assert_raise(Exception) { send_to_botpress_call.success? }
  end

  test "invalid endpoint" do
    stub_request(:post, Regexp.new(@botpress_endpoint))
      .with(@request_options).to_return(status: 404)

    result = send_to_botpress_call

    assert result.failure?
    assert_equal 'Invalid botpress endpoint', result.data[:message]
  end

  test "invalid bot" do
    stub_request(:post, Regexp.new(@botpress_endpoint))
      .with(@request_options)
      .to_return(
        status: 404,
        body: '{"statusCode":404,"errorCode":"BP_0044","type":"NotFoundError","message":"Not Found: Invalid Bot ID","details":"","docs":"https://botpress.com/docs"}',
      )

    result = send_to_botpress_call

    assert result.failure?
    assert_equal 'Invalid Bot ID', result.data[:message]
  end

  private

  def load_event(filename)
    JSON.parse(File.read(Rails.root.join("test/fixtures/files/#{filename}")))
  end

  def send_to_botpress_call
    Botpress::SelfHosted::Send.call(
      event: @event,
      botpress_endpoint: @botpress_endpoint,
      botpress_bot_id: @botpress_bot_id
    )
  end
end
