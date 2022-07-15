require "test_helper"

class ReceiveEventTest < ActionDispatch::IntegrationTest
  setup do
    @event = JSON.parse(File.read(Rails.root.to_s + "/test/fixtures/files/new_message.json"))
  end

  test "valid event" do
    result = Chatwoot::ValidEvent.call(event: @event).success?
    assert_equal true, result
  end

  test "should not valid event" do
    @event['conversation']['status'] = 'open'

    result = Chatwoot::ValidEvent.call(event: @event).failure?
    assert_equal true, result
  end

  test "valid event changed by env var" do
    mock_env('CHATWOOT_ALLOWED_STATUSES' => 'open') do
      @event['conversation']['status'] = 'open'

      result = Chatwoot::ValidEvent.call(event: @event).success?
      assert_equal true, result
    end
  end
end
